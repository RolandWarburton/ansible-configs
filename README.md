# Ansible Playbooks

Pairs with [rolandwarburton/dotfiles](https://github.com/RolandWarburton/dotfiles).

Editor config can be found at [rolandwarburton/nvim.conf](https://github.com/RolandWarburton/nvim.conf).

### Adding a New Ansible Host

Edit the host_vars file:

* Rename the IP to be correct in `hosts.ini`.
* Rename the `host_vars/<ip>` file to be correct.
* Edit the `host_vars/<ip>` file to contain the correct variables.

### Prepping Ansible Host

Copy your key to the host.

```none
ssh-copy-id -id ~/.ssh/id_rsa USERNAME@MACHINE
```

On the target, Generate a key for github and upload it, do not use a passphrase is recommended.

```none
ssh-keygen -f ~/.ssh/id_github
```

On the target, install sudo.

```none
apt install sudo
```

On the target, add the user to the suoders group

```none
usermod -aG sudo $USER
```

### Run the playbook

```none
ansible-playbook \
  ./playbooks/setup.yml --ask-become-pass
```
