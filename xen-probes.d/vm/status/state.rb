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

xenstore_text=`#{XENSTORE_PATH} -f /`
                                # [^0] -> exclude dom0
                                # (?<xxx>) -> only returns grouped exprs
regex = Regexp.new('^/local/domain/0/device-model/(?<domid>[0-9]+)/state = (?<state>.*)')
hosts_states = xenstore_text.scan(regex)
exit(0) if hosts_states.nil? or hosts_states.empty?

begin
    hosts_states.each{|domid, state|
        if domid == "0"
            next
        end

        # VM name
        regex = Regexp.new("^/local/domain/#{domid}/name = (?<val>.*)")
        vm_name = xenstore_text.match(regex)[:val].gsub('"', '')
        vm_id = vm_name.split("one-")[1].sub('"', '')
        # UUID
        regex = Regexp.new("^/local/domain/#{domid}/vm = (?<val>.*)")
        uuid = xenstore_text.match(regex)[:val].split("/")[2].gsub('"', '')

        print "VM = [ "             # open the VM block
        print 'ID=' + vm_id
        print ', DEPLOY_ID=' + domid
        print ', UUID=' + '"' + uuid + '"'
        print ', STATE=' + state.upcase
        print " ]\n"             # end the VM block
    }
rescue  StandardError => e
    puts e
end

exit(0)
