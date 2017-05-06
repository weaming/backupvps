**Backup my vps**

```
apt install git make -y && [ -d ~/src ] || mkdir ~/src && cd ~/src &&
git clone https://github.com/weaming/backupvps && cd backupvps && make install
```
