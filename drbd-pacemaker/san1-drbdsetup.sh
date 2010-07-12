
# We should now have a device called /dev/drbd0 that will
# host our iscsi config and a /dev/drbd1 that is our BFD.

mkdir -p /export/config
mkfs.ext4 /dev/drbd0
mount /dev/drbd0 /export/config

# Enable iscsitarget
sed -i s/false/true/ /etc/default/iscsitarget

# Remove iscsitarget from init, heartbeat will be in charge of it
update-rc.d -f iscsitarget remove

# Configure iscsi target devices
mv /etc/ietd.conf{,.orig}

# TODO: Needs a lot of work and full explanation of all resources
cat > /export/config/ietd.conf << __EOF__
Target iqn.2010-07.com.engineyard:storage01
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud "HAHAEYdev383"
	OutgoingUser engineyard-devcloud "HAHAEYdev383"
	Lun 0 Path=/dev/drbd01,Type=fileio
	Alias blade01
	MaxConnections         1
	InitialR2T             Yes
	ImmediateData          No
	MaxRecvDataSegmentLength 8192
	MaxXmitDataSegmentLength 8192
	MaxBurstLength         262144
	FirstBurstLength       65536
	DefaultTime2Wait       2
	DefaultTime2Retain     20
	MaxOutstandingR2T      8
	DataPDUInOrder         Yes
	DataSequenceInOrder    Yes
	ErrorRecoveryLevel     0
	Wthreads               8
__EOF__

# Symlink the configuration into place
ln -s /export/config/ietd.conf /etc/ietd.conf

# Unmount /export/config so it doesn't interfere with heartbeat
umount /export/config

cat > /etc/heartbeat/ha.cf << __EOF__
debug						1
use_logd					false
logfacility 				daemon
traditional_compression		off
compression					bz2
coredumps					true
udpport						691
bcast						bond0 bond1
autojoin					off
keepalive 					2
warntime					6
deadtime					10
initdead 					15
node 						pod1san1 pod1san2
crm 						respawn
__EOF__

# Going to need more IP's if we keep this design
cat > /etc/ha.d/haresources << __EOF__
pod1san1 drbddisk::iscsi.config Filesystem::/dev/drbd0::/export/config::ext4
pod1san1 IPaddr2::199.34.121.28/27/bond0 drbddisk::iscsi.blade.01 iscsitarget
pod1san1 IPaddr2::199.34.121.29/27/bond0 drbddisk::iscsi.blade.02 iscsitarget
__EOF__

# This failed. Heartbeat just wouldn't remain consistent. Not sure what's going on but moving to
# iscsi/RAID1 setup to begin testing so I am not wasting time.