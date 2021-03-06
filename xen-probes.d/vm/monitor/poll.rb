#!/usr/bin/env ruby

# ---------------------------------------------------------------------------- #
# Copyright 2020, E2E Networks Ltd. & OpenNebula Project, OpenNebula Systems   #
#                                                                              #
# Licensed under the Apache License, Version 2.0 (the "License"); you may      #
# not use this file except in compliance with the License. You may obtain      #
# a copy of the License at                                                     #
#                                                                              #
# http://www.apache.org/licenses/LICENSE-2.0                                   #
#                                                                              #
# Unless required by applicable law or agreed to in writing, software          #
# distributed under the License is distributed on an "AS IS" BASIS,            #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.     #
# See the License for the specific language governing permissions and          #
# limitations under the License.                                               #
#----------------------------------------------------------------------------- #

require "pp"
require "base64"

XENTOP_PATH="sudo /usr/sbin/xentop"
XENSTORE_PATH="sudo /usr/bin/xenstore-ls"

xentop_text=`#{XENTOP_PATH} -bi1 --full-name`
exit(-1) if $?.exitstatus != 0

lines=xentop_text.split("\n")
domains_info=lines[1..-1]

# DOMAINS LINES
xenstore_text=`#{XENSTORE_PATH} -f /local/domain`
domains_info.each {|line|
    stats = Hash.new

    l=line.strip.split

    # We only need VM stats not Dom-0
    if l[0] == "Domain-0"
        next
    end

    vm_name = l[0]
    vm_id = l[0].split("one-")[1]

    regex = Regexp.new("/local/domain/(?<domid>[0-9]+)/name = \"#{vm_name}\"")
    domid = xenstore_text.match(regex)
    if domid.nil?
        puts "=> Error: cannot find domid for #{vm_name}"
        next
    end
    domid = domid[:domid]

    regex = Regexp.new("/local/domain/#{domid}/vm = (?<val>.*)")
    uuid = xenstore_text.match(regex)
    if uuid.nil?
        puts "=> Error: cannot find UUID for #{vm_name}"
        next
    end
    uuid = uuid[:val].split("/")[2].gsub('"', '')

    print "VM = [ "             # open the VM block
    print 'ID="' + vm_id + '"'
    print ', DEPLOY_ID=' + domid
    print ', UUID="' + uuid + '"'

    stats['CPU'] = l[3].to_f
    stats['MEMORY'] = l[4].to_i
    stats['NETTX'] = l[10].to_i
    stats['NETRX'] = l[11].to_i
    stats['DISKRDIOPS'] = l[14].to_i
    stats['DISKWRIOPS'] = l[15].to_i
    stats['DISKRDBYTES'] = l[16].to_i * 512 # assuming sector size to be 512 bytes
    stats['DISKWRBYTES'] = l[17].to_i * 512

    monitor = String.new
    stats.each { |k ,v|
        monitor += k + '=' + '"' + v.to_s + '"' + "\n"
    }

    print ', MONITOR=' + '"' + Base64.strict_encode64(monitor) + '"'
    print " ]\n"  # close VM block
}

exit(0)
