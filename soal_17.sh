#menjalankan bind9 pd tirion dan valmar
update-rc.d named defaults

#menjalankan nginx pd sirion dan lindon
update-rc.d nginx defaults

#menjalankan ph-fpm pd vingilot
update-rc.d php8.4-fpm defaults

#lakukan perintah untuk membuka kunci file pd tirion
chattr -i /etc/resolv.conf

#jalankan layanan DNS pada tirion
service named start

#verifikasi layanan pada tirion
service named status

#kunci kembali file pd tirion
chattr +i /etc/resolv.conf
