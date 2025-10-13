#masuk ke sirion, buat file dan hapus semua isi file saat ini
nano /etc/nginx/sites-available/sirion.conf

#ganti dengan isi
# =======================================================
# BLOK PENGALIHAN (REDIRECT) - UNTUK SEMUA NAMA LAIN
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

    # Semua konfigurasi dari Soal 11 & 12 tetap di sini
    # Blok untuk melindungi /admin
    location /admin/ {
        auth_basic "Area Terlarang!";
        auth_basic_user_file /etc/nginx/.htpasswd;
        alias /var/www/html/;
    }

    # Blok untuk rute /static
    location /static/ {
        proxy_pass http://lindon.K01.com/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Blok untuk rute /app
    location /app/ {
        proxy_pass http://app.K01.com/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

#terapkan konfigurasi final
nginx -t && service nginx restart

#tes via IP Address (Earendil)
curl -I http://10.71.3.2/static/

#tes akses (sirion)
curl -I http://10.71.3.2/static/

#tes akses (earendil)
lynx http://www.K01.com/static/

