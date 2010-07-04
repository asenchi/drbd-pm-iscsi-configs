# parted to create one very large partition
parted
(parted) rm 1
(parted) rm 2
(parted) mklabel gpt
(parted) mkpart primary 0 -0
(parted) p
(parted) quit

# Install lvm2
apt-get -y install lvm2

# /dev/sda1 (14T)
pvcreate /dev/sda1

# We need to increase the extent size to support larger LV's
vgcreate -s 32M blades /dev/sda1

lvcreate -L1G -niscsiconfig blades
lvcreate -L1G -ndrbdmeta blades
for i in 0{1..9} {10..16}
do
	lvcreate -L790G -nblade$i blades
done
