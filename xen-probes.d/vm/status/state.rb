#!/usr/bin/env ruby

# -------------------------------------------------------------------------- #
# Copyright 2020, E2E Networks Ltd.                                          #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

XENSTORE_PATH="sudo /usr/bin/xenstore-ls"

def print_info(name, value)
    value = "0" if value.nil? or value.to_s.strip.empty?
    puts "#{name}=#{value}"
end

xenstore_text=`#{XENSTORE_PATH} -f /local/domain/0/device-model | grep state`
exit(-1) if $?.exitstatus != 0

lines=xenstore_text.split("\n")

begin
    lines.each {|line|
        l=line.strip.split
        domid = l[0].split("/")[-2]
        state = l[2].upcase

        # We only need VM stats not Dom-0
        if domid == "0"
            next
        end

        xenstore_text=`#{XENSTORE_PATH} -f /local/domain/#{domid} | grep name`
        vm_name = xenstore_text.strip.split[2].gsub('"', '')
        vm_id = vm_name.split("one-")[1].sub('"', '')

        xenstore_text=`#{XENSTORE_PATH} -f /local/domain/#{domid} | grep vm`
        uuid = xenstore_text.strip.split[2].split("/")[2].sub('"', '')

        print "VM = [ "         # open VM block
        print 'ID=' + vm_id
        print ', DEPLOY_ID=' + domid
        print ', UUID=' + '"' + uuid + '"'
        print ', STATE=' + state
        print " ]\n"            # end VM block
    }
rescue  StandardError => e
    puts e
end
