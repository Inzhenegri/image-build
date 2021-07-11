## Give Docker the right permissions
```
sudo chmod 666 /var/run/docker.sock
```

## Before connect to ssh past this code. You should change "arseny" to your linux username
```
ssh-keygen -f "/home/arseny/.ssh/known_hosts" -R "192.168.11.1"
```