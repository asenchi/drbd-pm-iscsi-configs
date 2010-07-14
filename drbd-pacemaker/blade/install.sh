NUM=16

hostname pod1blade$NUM.engineyard.com
sed -i '/HOSTNAME/d' /etc/sysconfig/network
echo "HOSTNAME=pod1blade$NUM.engineyard.com" >> /etc/sysconfig/network

yum -y groupinstall Base
yum -y install iscsi-initiator-utils wget procmail bc perl parted sysstat

cp conf/etc/iscsi/iscsid.conf /etc/iscsi/iscsid.conf

cat > /etc/iscsi/initiatorname.iscsi << __EOF__
InitiatorName=iqn.2010-07.com.engineyard.devcloud:pod1blade$NUM
__EOF__

chkconfig --level 2345 iscsi on
chkconfig --level 2345 iscsid on

/etc/init.d/iscsi start
iscsiadm -m discovery -t sendtargets -p 199.34.121.28
iscsiadm -m node -T iqn.2010-07.com.engineyard.devcloud:storage$NUM -p 199.34.121.28:3260 -l

# EDIT THIS TO REMOVE ALL TARGETS OUTSIDE OF THE ONE WE LOG INTO.
# Remove all targets except those ones destined for this blade
for i in 0{1..9} {10..15}; do rm -rf /var/lib/iscsi/nodes/*.storage$i; done

# Partition our new iscsi target
parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart primary 0 -0

# Create our filesystem optimized for two disks mirrored.
mkfs.ext3 -b 4096 -O dir_index /dev/sdb1

cd /root
wget http://download.parallels.com/virtuozzo/virtuozzo4.0/linux/vzinstall-linux.bin
chmod +x vzinstall-linux.bin
./vzinstall-linux.bin install --templates=full