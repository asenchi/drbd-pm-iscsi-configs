# POD1SAN2:
# IP: 199.34.121.27
# PASS: eypod1

# INTERFACES
# eth0: 199.34.121.27 - network

# Make sure no one runs this.
exit 1

hostname pod1san2.engineyard.com
echo pod1san2.engineyard.com > /etc/hostname

# COMMANDS
apt-get -y install ifenslave ntp sysstat lvm2 iscsitarget parted

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
	address 199.34.121.27
	netmask 255.255.255.224
	broadcast 199.34.121.31
	gateway 199.34.121.30
	network 199.34.121.29

auto eth1
iface eth1 inet manual

auto eth2
iface eth2 inet manual

auto eth3
iface eth3 inet manual
__EOF__

cat >> /etc/hosts << __EOF__
199.34.121.26 pod1san1.engineyard.com pod1san1
199.34.121.27 pod1san2.engineyard.com pod1san2
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

# Now, create 16 790G logical volumes, one for each of our blades
for i in 0{1..9} {10..16}
do
	lvcreate -L814G -nblade$i blades
done

mv /etc/ietd.conf{,.orig}
cat > /export/config/ietd.conf << __EOF__
Target iqn.2010-07.com.engineyard.pod1san2.storage01
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade01,Type=fileio
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
Target iqn.2010-07.com.engineyard.pod1san2.storage02
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade02,Type=fileio
	Alias blade02
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
Target iqn.2010-07.com.engineyard.pod1san2.storage03
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade03,Type=fileio
	Alias blade03
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
Target iqn.2010-07.com.engineyard.pod1san2.storage04
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade04,Type=fileio
	Alias blade04
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
Target iqn.2010-07.com.engineyard.pod1san2.storage05
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade05,Type=fileio
	Alias blade05
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
Target iqn.2010-07.com.engineyard.pod1san2.storage06
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade06,Type=fileio
	Alias blade06
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
Target iqn.2010-07.com.engineyard.pod1san2.storage07
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade07,Type=fileio
	Alias blade07
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
Target iqn.2010-07.com.engineyard.pod1san2.storage08
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade08,Type=fileio
	Alias blade08
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
Target iqn.2010-07.com.engineyard.pod1san2.storage09
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade09,Type=fileio
	Alias blade09
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
Target iqn.2010-07.com.engineyard.pod1san2.storage09
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade09,Type=fileio
	Alias blade09
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
Target iqn.2010-07.com.engineyard.pod1san2.storage10
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade10,Type=fileio
	Alias blade10
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
Target iqn.2010-07.com.engineyard.pod1san2.storage11
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade11,Type=fileio
	Alias blade11
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
Target iqn.2010-07.com.engineyard.pod1san2.storage12
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade12,Type=fileio
	Alias blade12
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
Target iqn.2010-07.com.engineyard.pod1san2.storage13
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade13,Type=fileio
	Alias blade13
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
Target iqn.2010-07.com.engineyard.pod1san2.storage14
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade14,Type=fileio
	Alias blade14
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
Target iqn.2010-07.com.engineyard.pod1san2.storage15
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade15,Type=fileio
	Alias blade15
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
Target iqn.2010-07.com.engineyard.pod1san2.storage16
	# Password is required to be 12 characters long
	IncomingUser engineyard-devcloud HAHAEYdev383
	OutgoingUser engineyard-devcloud HAHAEYdev384
	Lun 0 Path=/dev/blades/blade16,Type=fileio
	Alias blade16
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

update-rc.d iscsitarget defaults

# It's best to reboot here to make sure everything comes up.

# Verify with:
# cat /proc/net/iet/volume