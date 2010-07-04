hostname pod1san1
echo pod1san1 > /etc/hostname

apt-get -y install ifenslave ntp sysstat lvm2 drbd8-utils pacemaker iscsitarget