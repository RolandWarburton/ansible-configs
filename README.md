# Ansible Playbooks

Edit the host_vars file:

### Adding a New Ansible Host

* Rename the IP to be correct in `hosts.ini`.
* Rename the `host_vars/<ip>` file to be correct.
* Edit the `host_vars/<ip>` file to contain the correct variables.

### Prepping Ansible Host

Copy your key to the host.

```none
ssh-copy-id -id ~/.ssh/id_rsa USERNAME@MACHINE
```

Generate a key for github and upload it.

```none
ssh-keygen -f ~/.ssh/id_github
```

### Run the playbook

```none
ansible-playbook \
  ./playbooks/setup.yml --ask-become-pass
```
