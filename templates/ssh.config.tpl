Host bastion
  User                   root
  HostName               ${bastion_ip}
  ProxyCommand           none
  IdentityFile           ${identity_file}
  BatchMode              yes
  PasswordAuthentication no
  ForwardAgent           yes

Host *
  User ubuntu
  ProxyCommand           ssh -q -W %h:%p root@${bastion_ip}
  ForwardAgent           yes
  ServerAliveInterval    60
  TCPKeepAlive           yes
  ControlMaster          auto
  ControlPath            ~/.ssh/bastion-%r@%h:%p
  ControlPersist         8h
  IdentityFile           ${identity_file}