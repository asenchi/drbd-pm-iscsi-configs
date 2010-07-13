# We want to use short hostnames here, /etc/hosts has our main hostname config.
hostname pod1san1
echo pod1san1 > /etc/hostname

# Copy our interfaces, bonding config and hosts into place.
cp conf/etc/network/interfaces /etc/network/
cp conf/etc/modprobe.d/aliases.conf /etc/modprobe.d/
cp conf/etc/hosts /etc/hosts

reboot # Confirm everything is working

# Install the following packages:
#	ifenslave: this allows us to bond interfaces
#	ntp: sync clocks
#	sysstat: Lots of useful monitoring tutorials
#	lvm2: lvm package
#	drbd8-utils: drbd
#	iscsitarget: iscsi package
#	pacemaker: This will install openais which we will use instead of heartbeat
apt-get -y install ifenslave ntp sysstat lvm2 drbd8-utils iscsitarget pacemaker

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

# And one for our drbd meta data
lvcreate -L13G -ndrbdmeta blades

# Now, create 16 790G logical volumes, one for each of our blades
for i in 0{1..9} {10..16}
do
	lvcreate -L814G -nblade$i blades
done

# Copy our drbd.conf into place
cp conf/etc/drbd.conf /etc/drbd.conf

# Create the resources
drbdadm create-md all

# Set primary (ONLY RUN THIS ON POD1SAN1)
drbdadm -- --overwrite-data-of-peer primary all

# On initial sync we want to speed up the initialization:
# for i in {1..16}; do drbdsetup /dev/drbd$i syncer -r 110M; done
# To reset to default sync of 10M run:
# for i in 0{1..9} {10..16}; do drbdsetup adjust blade.$i; done

# Start drbd
/etc/init.d/drbd start

# We need to remove drbd from startup as pacemaker will take care of that for us
update-rc.d -f drbd remove

# Set pod1san1 as primary
drbdadm -- --overwrite-data-of-peer primary all

# corosync-keygen # We already have a key generated
cp conf/etc/corosync/authkey /etc/corosync/authkey
cp conf/etc/corosync/corosync.conf /etc/corosync/corosync.conf

# Set corosync to startup on boot
sed -e 's/START=no/START=yes/' -i /etc/defaults/corosync

# Startup corosync
/etc/init.d/corosync start

# Verify it's working
crm status
crm configure show

# Turn off quorum
crm configure property no-quorum-policy=ignore

# Turn off stonith for now
crm configure property stonith-enabled=false



# Scratch and out of band...
crm configure load update <textfile of commands to load>

# have to add --address=<ip> to /etc/init.d/iscsitarget :(
# instead we should just firewall off what we don't want.