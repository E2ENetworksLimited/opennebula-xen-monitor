#!/usr/bin/env ruby

# -------------------------------------------------------------------------- #
# Copyright 2002-2020, OpenNebula Project, OpenNebula Systems                #
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

INFO="sudo /usr/sbin/xl info"

info_text=`#{INFO}`

puts "HYPERVISOR=xen"

ncpu_text = info_text.match('^nr_cpus[ ]*:[ ]*(?<ncpu>[0-9]+)')
if info_text.nil?
    puts "Error: cannot find NCPUs"
end
puts "TOTALCPU=" + (ncpu_text[:ncpu].to_i * 100).to_s

cpuspeed_text = info_text.match('^cpu_mhz[ ]*:[ ]*(?<mhz>[0-9]+)')
if cpuspeed_text.nil?
    puts "Error: cannot find CPU speed"
end
puts "CPUSPEED=" + cpuspeed_text[:mhz]

memory_text = info_text.match('^total_memory[ ]*:[ ]*(?<mem>[0-9]+)')
if memory_text.nil?
    puts "Error: cannot find memory information"
end
                                                # convert MB to MiB
puts "TOTALMEMORY=" + ((memory_text[:mem].to_f / 1024) * 1000 * 1000).to_i.to_s
