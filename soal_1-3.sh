# Setup Config GNS3 Client

# Eonwe Network Configuration

# Interface untuk koneksi ke Internet (NAT)
auto eth0
iface eth0 inet dhcp

# Interface untuk Jalur Barat (ke Switch1)
auto eth1
iface eth1 inet static
	address 10.71.1.1
	netmask 255.255.255.0

# Interface untuk Jalur Timur (ke Switch2)
auto eth2
iface eth2 inet static
	address 10.71.2.1
	netmask 255.255.255.0

# Interface untuk Jalur DMZ (ke Switch3)
auto eth3
iface eth3 inet static
	address 10.71.3.1
	netmask 255.255.255.0

# Perintah `up` untuk menjalankan iptables secara otomatis saat interface aktif
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt update && apt install iptables
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.71.0.0/16
up apt-get install -y procps e2fsprogs iptables-persistent bind9 dnsutils ifupdown lynx nginx

# Konfigurasi Jaringan untuk Earendil
auto eth0
iface eth0 inet static
    address 10.71.1.2
    netmask 255.255.255.0
    gateway 10.71.1.1
    dns-nameservers 10.71.3.3 10.71.3.4 192.168.122.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt-get update
up apt-get install -y procps e2fsprogs iptables-persistent bind9 dnsutils ifupdown lynx nginx

# Elwing Network Configuration
auto eth0
iface eth0 inet static
	address 10.71.1.3
	netmask 255.255.255.0
	gateway 10.71.1.1
	dns-nameservers 10.71.3.3 10.71.3.4 192.168.122.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt-get update
up apt-get install -y procps e2fsprogs iptables-persistent bind9 dnsutils ifupdown lynx nginx

# Cirdan Network Configuration
auto eth0
iface eth0 inet static
	address 10.71.2.2
	netmask 255.255.255.0
	gateway 10.71.2.1
	dns-nameservers 10.71.3.3 10.71.3.4 192.168.122.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt-get update
up apt-get install -y procps e2fsprogs iptables-persistent bind9 dnsutils ifupdown lynx nginx

# Elrond Network Configuration
auto eth0
iface eth0 inet static
	address 10.71.2.3
	netmask 255.255.255.0
	gateway 10.71.2.1
	dns-nameservers 10.71.3.3 10.71.3.4 192.168.122.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt-get update
up apt-get install -y procps e2fsprogs iptables-persistent bind9 dnsutils ifupdown lynx nginx

# Maglor Network Configuration
auto eth0
iface eth0 inet static
	address 10.71.2.4
	netmask 255.255.255.0
	gateway 10.71.2.1
	dns-nameservers 10.71.3.3 10.71.3.4 192.168.122.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt-get update
up apt-get install -y procps e2fsprogs iptables-persistent bind9 dnsutils ifupdown lynx nginx

# Sirion Network Configuration
auto eth0
iface eth0 inet static
	address 10.71.3.2
	netmask 255.255.255.0
	gateway 10.71.3.1
	dns-nameservers 10.71.3.3 10.71.3.4 192.168.122.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt-get update
up apt-get install -y procps e2fsprogs iptables-persistent bind9 dnsutils ifupdown lynx nginx

# Tirion Network Configuration
auto eth0
iface eth0 inet static
	address 10.71.3.3
	netmask 255.255.255.0
	gateway 10.71.3.1
	up echo nameserver 192.168.122.1 > /etc/resolv.conf
	up apt-get update
	up apt-get install -y bind9
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt-get update
up apt-get install -y procps e2fsprogs iptables-persistent bind9 dnsutils ifupdown lynx nginx

# Valmar Network Configuration
auto eth0
iface eth0 inet static
	address 10.71.3.4
	netmask 255.255.255.0
	gateway 10.71.3.1
	up echo nameserver 192.168.122.1 > /etc/resolv.conf
	up apt-get update
	up apt-get install -y bind9
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt-get update
up apt-get install -y procps e2fsprogs iptables-persistent bind9 dnsutils ifupdown lynx nginx

# Lindon Network Configuration
auto eth0
iface eth0 inet static
	address 10.71.3.5
	netmask 255.255.255.0
	gateway 10.71.3.1
	dns-nameservers 10.71.3.3 10.71.3.4 192.168.122.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt-get update
up apt-get install -y procps e2fsprogs iptables-persistent bind9 dnsutils ifupdown lynx nginx

# Vingilot Network Configuration
auto eth0
iface eth0 inet static
	address 10.71.3.6
	netmask 255.255.255.0
	gateway 10.71.3.1
	dns-nameservers 10.71.3.3 10.71.3.4 192.168.122.1
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt-get update
up apt-get install -y procps e2fsprogs iptables-persistent bind9 dnsutils ifupdown lynx nginx