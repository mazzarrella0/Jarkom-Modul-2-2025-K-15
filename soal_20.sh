#buat dir khusus untuk page sirion
mkdir -p /var/www/sirion_beranda

#buat file index.html
nano /var/www/sirion_beranda/index.html

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>War of Wrath</title>
</head>
<body>
    <h1>War of Wrath: Lindon bertahan</h1>
    <p>Silakan telusuri kisah-kisah dari Beleriand:</p>
    <ul>
        <li><a href="/static/">Kunjungi Pelabuhan Statis (Lindon)</a></li>
        <li><a href="/app/">Dengarkan Kisah Dinamis (Vingilot)</a></li>
    </ul>
</body>
</html>

#perbarui konfigurasi nginx (sirion)
nano /etc/nginx/sites-available/sirion.conf

#isi dengan file akhir
# =======================================================
# BLOK PENGALIHAN (REDIRECT) - UNTUK SEMUA NAMA LAIN (Soal 13)
# =======================================================
server {
    # 'default_server' akan menangani semua permintaan yang tidak cocok
    # dengan server_name lain, termasuk akses via IP.
    listen 80 default_server;

    # Juga secara eksplisit menangani nama 'sirion'
    server_name sirion.K01.com;

    # Perintah untuk mengalihkan secara permanen (301) ke nama kanonik
    # '$request_uri' adalah variabel Nginx yang berisi path asli,
    # contoh: /admin/ atau /static/
    return 301 http://www.K01.com$request_uri;
}

# =======================================================
# BLOK UTAMA - UNTUK NAMA KANONIK 'www'
# =======================================================
server {
    listen 80;

    # Hanya merespons nama kanonik
    server_name www.K01.com;

    # Blok untuk melindungi /admin (Soal 12)
    location /admin/ {
        auth_basic "Area Terlarang!";
        auth_basic_user_file /etc/nginx/.htpasswd;
        alias /var/www/html/;
    }

    # Blok untuk rute /static (Soal 11)
    location /static/ {
        proxy_pass http://lindon.K01.com/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Blok untuk rute /app (Soal 11)
    location /app/ {
        proxy_pass http://app.K01.com/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # BLOK BARU UNTUK HALAMAN BERANDA (SOAL 20)
    location / {
        root /var/www/sirion_beranda;
        index index.html;
    }
}

#terapkan perubahan akhir (sirion)
nginx -t && service nginx restart

#coba akses page
lynx http://www.K15.com/

~selesaiii🥳🥳🎉