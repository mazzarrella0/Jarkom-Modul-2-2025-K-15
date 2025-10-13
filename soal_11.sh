# buat konfigurasi nginx sebagai reverse proxy
nano /etc/nginx/sites-available/reverse-proxy.conf

# isi konfigurasi 
server {
    listen 80;

    # Sirion akan merespons kedua nama ini
    server_name www.K15.com sirion.K15.com;

    # Lokasi untuk rute /static
    location /static/ {
        # Meneruskan permintaan ke server Lindon
        proxy_pass http://lindon.K15.com/;

        # Meneruskan header penting ke backend
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Lokasi untuk rute /app
    location /app/ {
        # Meneruskan permintaan ke server Vingilot
        proxy_pass http://app.K15.com/;

        # Meneruskan header penting ke backend
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# aktifkan situs 
ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/

# hapus link konfigurasi default nginx
rm /etc/nginx/sites-enabled/default
service nginx restart

# biar otomatis menyala ketika di boot ulang
update-rc.d nginx defaults

# untuk mengecek rute static
lynx http://www.K15.com/static/
# cek route app
lynx http://www.K15.com/app/
# coba akses via sirion
lynx http://sirion.K15.com/static/