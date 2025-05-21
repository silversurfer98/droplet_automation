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


## how to login so that discord notify works

ssh -o IdentitiesOnly=yes raghav@droplet.silver1618.fun

# Using loops in ansible playbook

```yaml
- name: Create login_notifier
  become_user: "{{ myuser }}"
  become: true
  file:
    path: /home/{{ myuser }}/login_notifier
    state: touch
    mode: '0755'
    owner: "{{ myuser }}"
    group: "{{ myuser }}"

- name: Write content to login_notifier
  become_user: "{{ myuser }}"
  become: true
  lineinfile:
    path: /home/{{ myuser }}/login_notifier
    line: "{{ item }}"
  loop:
    - "#!/bin/bash"
    - "WEBHOOK_URL={{ discord_hook }}"
    - "HOSTNAME=$(hostname -f)"
    - "DATE=\"$(date +\"%d.%b.%Y -- %H:%M\")\""
    - "MESSAGE=\"**$PAM_USER** did action: '**$PAM_TYPE**' at _$DATE on __$HOSTNAME from IP: \\`$PAM_RHOST\\`\""
    - "data='{\"content\":\"'\"${MESSAGE}\"'\",\"tts\":false}'"
    - "curl -X POST \"$WEBHOOK_URL\" -H \"Content-Type:application/json\" --data \"$data\""
```

# Using compose file directly

```yaml
- name: Join my tailsclae network
  become: true
  become_user: "{{ myuser }}"
  community.docker.docker_compose:
    project_name: tailscale
    definition:
      ---
      services:
        tailscale:
          container_name: tailscale
          image: tailscale/tailscale:stable
          hostname: tailscale-digitalocean
          security_opt:
            - no-new-privileges:true
          volumes:
            - /home/{{ myuser }}/tailscale:/var/lib/tailscale
            - /dev/net/tun:/dev/net/tun
          network_mode: "host"
          cap_add:
            - NET_ADMIN
            - NET_RAW
          environment:
            - TS_STATE_DIR=/var/lib/tailscale
            - TS_EXTRA_ARGS=--login-server={{ my_tailscale_web }} --advertise-exit-node --advertise-routes=192.168.1.0/24 --accept-dns=true
            - TS_NO_LOGS_NO_SUPPORT=true
            - TS_AUTHKEY={{ my_token }}  
          restart: unless-stopped
```