# Useful cmds

adding user, set password, add to sudo group

```sh
adduser newuser
passwd newuser
usermod -aG wheel newuser # for redhat based
usermod -aG sudo newuser # for debian based

# or for non root user
sudo adduser newuser
sudo passwd newuser
sudo usermod -aG wheel newuser # for redhat based
sudo usermod -aG sudo newuser # for debian based
```

check `sudo` group

```sh
sudo whoami
```
