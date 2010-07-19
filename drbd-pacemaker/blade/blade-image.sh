yum -y groupinstall Base
yum -y install iscsi-initiator-utils parted sysstat
wget http://download.parallels.com/virtuozzo/virtuozzo4.0/linux/vzinstall-linux.bin
chmod +x vzinstall-linux.bin
./vzinstall-linux.bin install --templates=full # requires a reboot
mkdir /root/virtuozzo-dist
bash /root/virtuozzo/download/Linux/x86_64/virtuozzo-*-x86_64.sfx -d /root/virtuozzo-dist --extract
vzsveinstall -f -v -D /root/virtuozzo-dist -s $(vzlist -a|grep ServiceCT|awk '{print $4}')
vzlicload -p <license>
vzup2date -z # install our templates
