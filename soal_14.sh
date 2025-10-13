#masuk ke vingilot mengganti baris access_log pada nano
##
        # Logging Settings
        ##

        # HAPUS ATAU BERI TANDA KOMENTAR PADA BARIS INI KARENA KITA AKAN MENGATURNYA DI SITUS SPESIFIK
        # access_log /var/log/nginx/access.log;
        
        # ==========================================================
        # TAMBAHKAN FORMAT LOG BARU DI SINI
        # ==========================================================
        log_format proxy '$http_x_real_ip - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         '"$http_referer" "$http_user_agent"';

#tambahkan baris access_log ke server {..}
server {
    listen 80;
    root /var/www/app.K15.com;
    index index.php;
    server_name app.K15.com;

    # ==========================================================
    # TAMBAHKAN BARIS INI UNTUK MENGGUNAKAN FORMAT LOG BARU
    # ==========================================================
    access_log /var/log/nginx/access.log proxy;

    # ... semua blok location dari soal 10 ...
}

#terapkan perubahan di vingilot
nginx -t && service nginx restart

#verifikasi di earendil (akses situs app dr sirion utk log di vingilot)
lynx http://www.K15.com/app/

#periksa "logbook" di vingilot
tail -n 1 /var/log/nginx/access.log

