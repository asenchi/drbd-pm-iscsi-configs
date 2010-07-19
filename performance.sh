cat >> /etc/sysctl.conf << __EOF__
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_mem = 16777216 16777216 16777216
net.ipv4.tcp_window_scaling = 1
et.ipv4.tcp_syncookies = 1
net.core.netdev_max_backlog = 2500
net.core.netdev_max_backlog = 2500
__EOF__