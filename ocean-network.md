# Ocean Network

docker network create \
    --driver macvlan \
    --opt parent=enp0s31f6 \
    --opt macvlan_mode=bridge \
    --subnet=10.0.0.0/16 \
    --gateway=10.0.0.1 \
    --ip-range=10.0.1.64/26 \
    --aux-address='host=10.0.1.64' ocean

to ping containers from the host

/etc/network/interfaces <<<
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
#iface enp0s31f6 inet dhcp

auto enp0s31f6
iface enp0s31f6 inet static
    address 10.0.1.4
    netmask 255.255.0.0
    gateway 10.0.0.1
    dns-nameservers 10.0.1.1, 1.1.1.1
    dns-search home

    up ip addr add 192.168.0.1/24 dev enp0s31f6
    down ip addr del 192.168.0.1/24 dev enp0s31f6

auto ocean-shim
iface ocean-shim inet static
    address 10.0.1.64
    netmask 255.255.255.255
    pre-up ip link add ocean-shim link enp0s31f6 type macvlan mode bridge
    post-up ip route add 10.0.1.64/26 dev ocean-shim
    post-down ip link del ocean-shim
>>>

ou

/etc/rc.local <<<
#!/bin/sh -e

ip link add ocean-shim link enp0s31f6 type macvlan mode bridge
ip addr add 10.0.1.64/32 dev ocean-shim
ip link set ocean-shim up
ip route add 10.0.1.64/26 dev ocean-shim
>>>

[Instructions](https://blog.oddbit.com/post/2018-03-12-using-docker-macvlan-networks/)
