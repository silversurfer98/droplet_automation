# To connect with droplet via ssh

> Since the IP of on-demand droplet changes we should not store in known hosts file

Add these to ssh config file to skip 
```
Host *.silver1618.fun 
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  User root
  LogLevel QUIET
```

use this command to play
ansible-playbook setup_tailscale.yaml --ask-vault-password