# Di vingilot cek  apakah ada nginx dlu

apt-get update
apt-get install -y nginx php8.4-fpm

# lalu pembuatan web dinamis
mkdir -p /var/www/app.K15.com

# halaman utama (index.php)
echo "<h1>Vingilot Mengisahkan Cerita Dinamis!</h1><p>Ini adalah halaman beranda.</p>" > /var/www/app.K15.com/index.php

# buat about.php
echo "<h2>Ini adalah halaman About dari Vingilot.</h2>" > /var/www/app.K15.com/about.php

# buat file konfigurasi baru 
nano /etc/nginx/sites-available/app.K15.com

# didalamnya 
server {
    listen 80;

    # Direktori utama website
    root /var/www/app.K15.com;

    # File yang akan dicari sebagai halaman utama
    index index.php;

    # Nama domain yang akan direspons
    server_name app.K15.com;

    # Blok utama untuk menangani URL
    location / {
        # Coba temukan file/folder yang cocok, jika tidak ada, arahkan ke index.php
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Blok untuk menjalankan file PHP
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        # Pastikan path socket ini benar untuk versi PHP Anda
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    # Blok untuk menerapkan URL Rewrite untuk /about
    # Ini akan secara internal mengubah permintaan /about menjadi /about.php
    location = /about {
        try_files $uri /about.php;
    }
}

# jalankan php-fpm
service php8.4-fpm start
# Buat agar otomatis menyala saat boot
update-rc.d php8.4-fpm defaults

# pembuatan verifikasi di klien (contoh:earendil)
lynx http://app.K15.com

# pembuatan verifikasi di klien untuk about
lynx http://app.K15.com/about