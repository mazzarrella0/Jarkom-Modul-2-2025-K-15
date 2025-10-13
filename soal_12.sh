# apache2-utils untuk mendapatkan perintah htpasswd
apt-get install -y apache2-utils

# buat file file .htpasswd untuk membuat user dan password
htpasswd -cb /etc/nginx/.htpasswd admin admin123

# /etc/nginx/sites-available/sirion.conf
server {
    listen 80 default_server;
    server_name www.K15.com sirion.K15.com;

    # Blok untuk melindungi /admin
    location /admin/ {
        auth_basic "Area Terlarang! Masukkan Kredensial!";
        auth_basic_user_file /etc/nginx/.htpasswd;

        # 'alias' adalah kunci keberhasilan.
        # Ini memetakan URL /admin/ langsung ke direktori fisik /var/www/html/
        alias /var/www/html/;
    }
}

# memastikan user masuk ke /etc/nginx
chmod 755 /etc/nginx

# izin pada file kata sandi 
chown www-data:www-data /etc/nginx/.htpasswd
chmod 640 /etc/nginx/.htpasswd

# aktifkan konfigurasi 
ln -s /etc/nginx/sites-available/sirion.conf /etc/nginx/sites-enabled/

# hapus default 
rm -f /etc/nginx/sites-enabled/default

# restart
service nginx stop
killall nginx || true
service nginx start

# cek kalau pakai kredensial diberhasil dan tidak apabila tanpa kredensial 
lynx http://www.K15.com/admin/
lynx -auth=admin:admin123 http://www.K15.com/admin/