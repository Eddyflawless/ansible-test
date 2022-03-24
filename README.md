# ansible-test

# useful commands

# ping all host specified in inventory
ansible all -m ping

# list all hosts
ansible all --list-hosts

# describe hosts instances
ansible all -m gather_facts [--limit 172.10.3.4]
