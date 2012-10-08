maintainer       "Alex Dergachev"
maintainer_email "alex@evolvingweb.ca"
license          "Apache 2.0"
description      "Allows chef-solo running as root to support ssh-agent forwarding"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1"

supports "ubuntu"
supports "debian"
supports "mac_os_x"
supports "openbsd"
supports "suse"

recipe "root_ssh_agent::env_keep", 'Adds \'Defaults env_keep += "SSH_AUTH_SOCK"\' to /etc/sudoers.d/ssh_env_keep.'
recipe "root_ssh_agent::ppid", "Sets $SSH_AUTH_SOCK to same value as that of the parent process."
