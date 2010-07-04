NUM=16

hostname pod1blade$NUM.engineyard.com
sed -i '/HOSTNAME/d' /etc/sysconfig/network
echo "HOSTNAME=pod1blade$NUM.engineyard.com" >> /etc/sysconfig/network

yum -y groupinstall Base
yum -y install iscsi-initiator-utils wget procmail bc perl mdadm parted sysstat

cat > /etc/iscsi/iscsi.conf << __EOF__
node.startup = automatic
node.conn[0].startup = automatic
node.session.auth.authmethod = CHAP
node.session.auth.username = engineyard-devcloud
node.session.auth.password = HAHAEYdev383
node.session.auth.username_in = engineyard-devcloud
node.session.auth.password_in = HAHAEYdev384
discovery.sendtargets.auth.authmethod = CHAP
discovery.sendtargets.auth.username = engineyard-devcloud
discovery.sendtargets.auth.password = HAHAEYdev383
node.session.timeo.replacement_timeout = 120
node.conn[0].timeo.login_timeout = 15
node.conn[0].timeo.logout_timeout = 15
node.conn[0].timeo.noop_out_interval = 5
node.conn[0].timeo.noop_out_timeout = 5
node.session.err_timeo.abort_timeout = 15
node.session.err_timeo.lu_reset_timeout = 20
node.session.initial_login_retry_max = 8
node.session.cmds_max = 128
node.session.queue_depth = 32
node.session.iscsi.InitialR2T = Yes
node.session.iscsi.ImmediateData = No
node.session.iscsi.FirstBurstLength = 262144
node.session.iscsi.MaxBurstLength = 16776192
node.conn[0].iscsi.MaxRecvDataSegmentLength = 131072
discovery.sendtargets.iscsi.MaxRecvDataSegmentLength = 32768
node.session.iscsi.FastAbort = Yes
__EOF__

cat > /etc/iscsi/initiatorname.iscsi << __EOF__
InitiatorName=iqn.2010-07.com.engineyard:pod1blade$NUM
__EOF__

chkconfig --level 2345 iscsi on
chkconfig --level 2345 iscsid on

/etc/init.d/iscsi start
iscsiadm -m discovery -t sendtargets -p pod1san1.engineyard.com
iscsiadm -m discovery -t sendtargets -p pod1san2.engineyard.com

# Remove all targets except those ones destined for this blade
for i in 0{1..9} {10..15}; do rm -rf /var/lib/iscsi/nodes/*.storage$i; done

# Create the raid device with our two partitions
mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1

# Create our filesystem optimized for two disks mirrored.
mkfs.ext3 -b 4096 -E stride=16 -O dir_index /dev/md0

cd /root
wget http://download.parallels.com/virtuozzo/virtuozzo4.0/linux/vzinstall-linux.bin
chmod +x vzinstall-linux.bin
./vzinstall-linux.bin install --templates=full


# iscsiadm -m node -T <target> -o delete

Abysmal performance during a sync anywhere from 2-10Mbps writes.