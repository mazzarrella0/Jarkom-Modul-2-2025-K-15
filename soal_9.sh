# masuk ke lindon dan buat file nano setup_lindon_web.sh dan isi dengan

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

# dan verifikasi dengan menjalankan command ini di node bebas

lynx http://static.K15.com/annals/

# apabila memunculkan catatan_kuno.txt maka verifikasi berhasil