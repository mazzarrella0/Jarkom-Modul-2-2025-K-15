#masuk ke tirion dan buka file
nano /etc/bind/K01/K01.com.db

#ubah isi nano
...
@       IN      SOA     ns1.K01.com. root.K01.com. (
                    2025101304      ; Serial NAIKKAN LAGI!
...
lindon      30      IN      A       10.71.3.50  ; <-- UBAH IP & TAMBAHKAN TTL
...
static      30      IN      CNAME   lindon.K01.com. ; <-- TAMBAHKAN TTL
...

berubah menjadi >>>>>>>

$TTL    604800
@       IN      SOA     ns1.K01.com. root.K01.com. (
                        2025101302      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
; Name Servers
@       IN      NS      ns1.K01.com.
@       IN      NS      ns2.K01.com.
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
lindon      30      IN      A       10.71.3.50
vingilot    IN      A       10.71.3.6
;
; CNAME RECORDS (SOAL 7)
www         IN      CNAME   sirion.K01.com.
static      30      IN      CNAME   lindon.K01.com.
app         IN      CNAME   vingilot.K01.com.

#restart BIND9
service named restart

#masuk ke earendil dan verifikasi
dig static.K01.com