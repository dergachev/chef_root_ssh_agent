#
# Cookbook Name::  root_ssh_agent
# Recipe:: ppid
#
# Copyright 2012, Alex Dergachev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


# SEE: http://stackoverflow.com/a/8191279/504018

# Uncomment the following to suppress StrictHostKeyChecking for the root user

# Directory "/root/.ssh" do
#   action :create
#   mode 0700
# end
# 
# File "/root/.ssh/config" do
#   action :create
#   content "Host *\\nStrictHostKeyChecking no"
#   mode 0600
# end


ruby_block "Give root access to the forwarded ssh agent" do
  block do
    # find a parent process' ssh agent socket
    agents = {}
    ppid = Process.ppid
    Dir.glob('/tmp/ssh*/agent*').each do |fn|
      agents[fn.match(/agent\.(\d+)$/)[1]] = fn
    end
    while ppid != '1'
      if (agent = agents[ppid])
        ENV['SSH_AUTH_SOCK'] = agent
        break
      end
      File.open("/proc/#{ppid}/status", "r") do |file|
        ppid = file.read().match(/PPid:\s+(\d+)/)[1]
      end
    end
    # Uncomment to require that an ssh-agent be available
    # fail "Could not find running ssh agent - Is config.ssh.forward_agent enabled in Vagrantfile?" unless ENV['SSH_AUTH_SOCK']
  end
  action :create
end

# Uncomment to require that a running ssh-agent has at least one key
# bash "verify agent forwarding" do
#   code "ssh-add -l" #returns 0 only if an identity is found
# end
