#masuk ke tirion dan perbarui file
$TTL    604800
@       IN      SOA     ns1.K15.com. root.K15.com. (
                        2025101307      ; Serial (pastikan ini yang terbaru)
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
; Name Servers (Soal 4)
@       IN      NS      ns1.K15.com.
@       IN      NS      ns2.K15.com.
;
; A Records for Name Servers and Apex (Soal 4)
ns1     IN      A       10.71.3.3       ; IP Tirion
ns2     IN      A       10.71.3.4       ; IP Valmar
@       IN      A       10.71.3.2       ; IP Sirion (Front Door)

;------------------------------------
; A RECORDS UNTUK SEMUA HOST (SOAL 5)
;------------------------------------
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

;------------------------------------
; CNAME RECORDS (SOAL 7 & 19)
;------------------------------------
www         IN      CNAME   sirion.K15.com.
static      IN      CNAME   lindon.K15.com.
app         IN      CNAME   vingilot.K15.com.
havens      IN      CNAME   www.K15.com.

;------------------------------------
; RECORDS UNTUK MELKOR (SOAL 18)
;------------------------------------
melkor      IN      TXT     "Morgoth (Melkor)"
morgoth     IN      CNAME   melkor.K15.com.

#restart layanan bind9
service named restart

#verifikasi pd earendil dan tes dns
dig havens.K15.com

#jangan lupa utk kunci file kembali pd sirion
chattr -i /etc/resolv.conf

#cek dengan nginx di sirion
nginx -t

#jalankan layanan nginx dan verifikasi status
service nginx start
service nginx status

#masuk ke earendil dan verifikasi akhir dgn lynx
lynx http://havens.K15.com/static/
