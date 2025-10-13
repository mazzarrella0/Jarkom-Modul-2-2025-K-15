# Diajalankan di Tirion

# buat nano setup_all_dns_records.sh dan isi dengan

#!/bin/bash
set -e
echo ">>> Menambahkan semua A, CNAME, dan PTR records..."

# Hapus semua isi file zona dan ganti dengan template lengkap
cat <<'EOF' > /etc/bind/K15/K15.com.db
$TTL    604800
@       IN      SOA     ns1.K15.com. root.K15.com. (
                    2025101301      ; Serial
                    604800          ; Refresh
                    86400           ; Retry
                    2419200         ; Expire
                    604800 )        ; Negative Cache TTL
;
; Name Servers
@       IN      NS      ns1.K15.com.
@       IN      NS      ns2.K15.com.
;
; A Records for Name Servers and Apex
ns1     IN      A       10.71.3.3
ns2     IN      A       10.71.3.4
@       IN      A       10.71.3.2
;
; A RECORDS UNTUK SEMUA HOST (SOAL 5)
eonwe       IN      A       10.71.1.1
earendil    IN      A       10.71.1.2
elwing      IN      A       10.71.1.3
cirdan      IN      A       10.71.2.2
elrond      IN      A       10.71.2.3
maglor      IN      A       10.71.2.4
sirion      IN      A       10.71.3.2
tirion      IN      A       10.71.3.3
valmar      IN      A       10.71.3.4
lindon      IN      A       10.71.3.5
vingilot    IN      A       10.71.3.6
;
; CNAME RECORDS (SOAL 7)
www         IN      CNAME   sirion.K15.com.
static      IN      CNAME   lindon.K15.com.
app         IN      CNAME   vingilot.K15.com.
EOF

# Menambahkan konfigurasi Reverse DNS (Soal 8)
echo 'zone "3.71.10.in-addr.arpa" { type master; file "/etc/bind/K15/rev.3.71.10.db"; allow-transfer { 10.71.3.4; }; };' >> /etc/bind/named.conf.local

cat <<'EOF' > /etc/bind/K15/rev.3.71.10.db
$TTL    604800
@       IN      SOA     ns1.K15.com. root.K15.com. (
                    2025101301      ; Serial
                    604800          ; Refresh
                    86400           ; Retry
                    2419200         ; Expire
                    604800 )        ; Negative Cache TTL
;
; Name Servers
@       IN      NS      ns1.K15.com.
@       IN      NS      ns2.K15.com.
;
; PTR Records for DMZ Hosts
2       IN      PTR     sirion.K15.com.
5       IN      PTR     lindon.K15.com.
6       IN      PTR     vingilot.K15.com.
EOF

echo ">>> Memperbaiki izin file lagi untuk file baru..."
chown bind:bind /etc/bind/K15/rev.3.71.10.db

echo ">>> Merestart Tirion..."
service named restart

echo "✅ Semua records DNS (Soal 5, 7, 8) telah dikonfigurasi."

# buat file sh di setiap node setup_client_final.sh lalu jalankan dengan ./setup_client_final.sh "nama node"

#!/bin/bash
set -e
echo ">>> Membuat konten web..."
mkdir -p /var/www/static.K15.com/annals
echo "<h1>Selamat Datang di Pelabuhan Statis Lindon</h1>" > /var/www/static.K15.com/index.html
echo "Ini adalah catatan dari Zaman Pertama." > /var/www/static.K15.com/annals/catatan_kuno.txt

echo ">>> Membuat file konfigurasi Nginx..."
cat <<'EOF' > /etc/nginx/sites-available/static.K15.com
server {
    listen 80;
    root /var/www/static.K15.com;
    index index.html;
    server_name static.K15.com;
    location /annals/ {
        autoindex on;
    }
}
EOF

echo ">>> Mengaktifkan situs dan membuatnya permanen..."
ln -sfn /etc/nginx/sites-available/static.K15.com /etc/nginx/sites-enabled/static.K15.com
rm -f /etc/nginx/sites-enabled/default
service nginx restart
update-rc.d nginx defaults

echo "✅ Konfigurasi Lindon sebagai web server SELESAI."
