# root-ssh-agent

## Description

A chef recipe that will allow "sudo su root" to maintain the ssh agent.
This is necessary for vagrant & chef-solo to work with ssh-agent forwarding.

## Installation

Clone this repository into your `CHEF-REPO/cookbooks/root_ssh_agent`:
    # Be sure to name the cookbook "root_ssh_agent", not "chef_root_ssh_agent"
    git clone git@github.com:dergachev/chef_root_ssh_agent.git root_ssh_agent

## Usage

Simply include `recipe[root_ssh_agent::ppid]` in your run\_list, and
subsequently chef-solo running as root (the behavior under vagrant) will have
access to your SSH_AUTH_SOCK variable, and consequently will have access your
running ssh-agent instance.

## Recipes

### env-keep

Adds the following to `/etc/sudoers.d/root_ssh_agent`: 

    Defaults env_keep += "SSH_AUTH_SOCK"

Because it works by changing /etc/sudoers.d, this recipe will not affect the
current shell session within which chef-client/chef-solo are running. Use
`recipe[root_ssh_agent::ppid]` if you need to allow agent forwarding during a
chef run.

### ppid

Uses the `ppid` (parent process id) to find the `$SSH_AUTH_SOCK` path
associated with the parent process (which presumably has the forwarded keys),
and sets that as `$SSH_AUTH_SOCK`.

Because it works by setting an environment variable, this recipe only affects
the current chef-client/chef-solo shell session. Use
`recipe[root_ssh_agent::env_keep]` for a permanent fix.

## Caveats

Please note if a cookbook executes commands as a non-root user (eg
chef-homesick), they will not have permission to access file referenced in
`$SSH_AUTH_SOCK`, and forwarding will fail even with
`recipe[root-ssh-agent::ppid]`. 

One work-around might be to modify your recipe to use `ssh user@localhost`
instead of `su otheruser`. For an example of this, see
https://github.com/dergachev/chef_homesick_agent

Of course, this only works if your private key allows you to log-in as that
user.

## Misc notes

See the following resources:
* http://stackoverflow.com/questions/7211287/use-ssh-keys-with-passphrase-on-a-vagrantchef-setup
* http://serverfault.com/questions/107187/sudo-su-username-while-keeping-ssh-key-forwarding#answer-118932

Vagrant boxes are supposed to include the following in sudoers, in practice they don't.
See https://github.com/mitchellh/vagrant/issues/1151
This can be fixed by including `recipe[root_ssh_agent::env_keep]` when building a base vagrant box.

Debugging tips: 
* `sudo su -` resets all env variables, no matter what /etc/sudoers env_keep specifies. "sudo su" or "sudo su root" doesn't.
* `fail @variable.to_yaml` is a good way to debug a recipe from ruby
* `ssh-add -l && false` is a good way to debug a recipe's command resource
* `sudo VISUAL=vim visudo -f /etc/sudoers.d/env_keep_sshauth
