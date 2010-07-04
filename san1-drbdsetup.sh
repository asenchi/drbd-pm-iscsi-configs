# POD1SAN1:
# IP: 199.34.121.26
# PASS: eypod1

# INTERFACES
# bond0: 199.34.121.26 (eth0, eth1) - network
# bond1: 10.10.1.11 (eth2, eth3) - crossover
# heartbeat: 199.34.121.28

hostname pod1san1

# COMMANDS
apt-get -y install ifenslave ntp sysstat lvm2 drbd8-utils iscsitarget heartbeat pacemaker

# Setup bonding in modprobe
cat >> /etc/modprobe.d/aliases.conf << __EOF__
alias bond0 bonding
options bond0 mode=0 miimon=100 downdelay=200 updelay=200 max_bonds=2
alias bond1 bonding
options bond1 mode=0 miimon=100 downdelay=200 updelay=200 max_bonds=2
__EOF__

# Configure our 4 additional interfaces for bonding
cat > /etc/network/interfaces << __EOF__
# The loopback network interface
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet manual

auto eth1
iface eth1 inet manual

# The primary network interface
auto bond0
iface bond0 inet static
        address 199.34.121.26
        netmask 255.255.255.224
        broadcast 199.34.121.31
        gateway 199.34.121.30
        network 199.34.121.29
		slaves eth0 eth1

# Member of bond1
auto eth2
iface eth2 inet manual

# Member of bond1
auto eth3
iface eth3 inet manual

# Network between two SAN devices
auto bond1
iface bond1 inet static
        address 10.10.1.11
        netmask 255.255.255.0
        broadcast 10.10.1.255
        network 10.10.1.0
		slaves eth2 eth3
__EOF__

cat >> /etc/hosts << __EOF__
199.34.121.26 pod1san1.engineyard.com pod1san1
199.34.121.27 pod1san2.engineyard.com pod1san2
10.10.1.11 pod1san1priv.engineyard.private pod1san1priv
10.10.1.12 pod1san2priv.engineyard.private pod1san2priv
__EOF__

# Partition
# We need to create out everything on our giant array and set it up
# for LVM. The following parted commands all take place with in the 
# parted tool (parted).
parted /dev/sda
# (parted) rm 1
# (parted) rm 2
# (parted) mklabel gpt
# (parted) mkpart primary 0 -0
# (parted) quit

# Setup /dev/sda1 as a physical volume for us to put our volume group
pvcreate /dev/sda1

# Create our volume group with 32M extents. This supports our 13T.
vgcreate -s 32M blades /dev/sda1

# Setup a 1G slice for our iscsi configuration
lvcreate -L1G -niscsiconfig blades

# And one for our drbd meta data
lvcreate -L12G -ndrbdmeta blades

# Now, create 16 790G logical volumes, one for each of our blades
for i in 0{1..9} {10..16}
do
	lvcreate -L814G -nblade$i blades
done

# Since we are using heartbeat, we need to give it access to files
chgrp haclient /sbin/drbdsetup
chmod o-x /sbin/drbdsetup
chmod u+s /sbin/drbdsetup
chgrp haclient /sbin/drbdmeta
chmod o-x /sbin/drbdmeta
chmod u+s /sbin/drbdmeta

# TODO: Need to finalize actions based on io-error, etc

cat >> /etc/drbd.conf << __EOF__
include "drbd.d/global_common.conf";
resource iscsi.config {
	protocol C;
	device  /dev/drbd0;
	disk    /dev/blades/iscsiconfig;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7780;
	floating 10.10.1.12:7780;
}

resource iscsi.blade.01 {
	protocol C;
	device  /dev/drbd01;
	disk    /dev/blades/blade01;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7781;
	floating 10.10.1.12:7781;
}

resource iscsi.blade.02 {
	protocol C;
	device  /dev/drbd02;
	disk    /dev/blades/blade02;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7782;
	floating 10.10.1.12:7782;
}

resource iscsi.blade.03 {
	protocol C;
	device  /dev/drbd03;
	disk    /dev/blades/blade03;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7783;
	floating 10.10.1.12:7783;
}

resource iscsi.blade.04 {
	protocol C;
	device  /dev/drbd04;
	disk    /dev/blades/blade04;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7784;
	floating 10.10.1.12:7784;
}

resource iscsi.blade.05 {
	protocol C;
	device  /dev/drbd05;
	disk    /dev/blades/blade05;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7785;
	floating 10.10.1.12:7785;
}

resource iscsi.blade.06 {
	protocol C;
	device  /dev/drbd06;
	disk    /dev/blades/blade06;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7786;
	floating 10.10.1.12:7786;
}

resource iscsi.blade.07 {
	protocol C;
	device  /dev/drbd07;
	disk    /dev/blades/blade07;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7787;
	floating 10.10.1.12:7787;
}

resource iscsi.blade.08 {
	protocol C;
	device  /dev/drbd08;
	disk    /dev/blades/blade08;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7788;
	floating 10.10.1.12:7788;
}

resource iscsi.blade.09 {
	protocol C;
	device  /dev/drbd09;
	disk    /dev/blades/blade09;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7789;
	floating 10.10.1.12:7789;
}

resource iscsi.blade.10 {
	protocol C;
	device  /dev/drbd10;
	disk    /dev/blades/blade10;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7790;
	floating 10.10.1.12:7790;
}

resource iscsi.blade.11 {
	protocol C;
	device  /dev/drbd11;
	disk    /dev/blades/blade11;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7791;
	floating 10.10.1.12:7791;
}

resource iscsi.blade.12 {
	protocol C;
	device  /dev/drbd12;
	disk    /dev/blades/blade12;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7792;
	floating 10.10.1.12:7792;
}

resource iscsi.blade.13 {
	protocol C;
	device  /dev/drbd13;
	disk    /dev/blades/blade13;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7793;
	floating 10.10.1.12:7793;
}

resource iscsi.blade.14 {
	protocol C;
	device  /dev/drbd14;
	disk    /dev/blades/blade14;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7794;
	floating 10.10.1.12:7794;
}

resource iscsi.blade.15 {
	protocol C;
	device  /dev/drbd15;
	disk    /dev/blades/blade15;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7795;
	floating 10.10.1.12:7795;
}

resource iscsi.blade.16 {
	protocol C;
	device  /dev/drbd16;
	disk    /dev/blades/blade16;
	flexible-meta-disk /dev/blades/drbdmeta;

	net {
	cram-hmac-alg sha1;
	shared-secret "HAHAEngineYardDevCLOUD10";
	}

	# Configuration inherits from primary resource
	floating 10.10.1.11:7796;
	floating 10.10.1.12:7796;
}
__EOF__

drbdadm create-md all
/etc/init.d/drbd start

# Set primary on SAN1 for both of our devices (this will typically be handled by heartbeat)
drbdadm -- --overwrite-data-of-peer primary all

# Increase the sync speed on initial create for all devices
# (don't run this in production)
for i in {1..16}; do drbdsetup /dev/drbd$i syncer -r 110M; done

# In order to set back to default speeds
for i in 0{1..9} {10..16}; do drbdsetup adjust iscsi.blade.$i; done

# Wait for sync to complete, monitor via 'cat /proc/drbd'

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
Target iqn.2010-07.com.engineyard.storage01
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud "HAHAEYdev383"
	OutgoingUser 
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