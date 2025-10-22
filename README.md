# Jarkom-Modul-2-2025-K-15


|No|Nama anggota|NRP|
|---|---|---|
|1. | Evan Christian Nainggolan | 5027241026|
|2. | Az Zahrra Tasya Adelia | 5027241087|



## Deskripsi Proyek
Proyek ini mencakup pembangunan infrastruktur jaringan dan layanan web lengkap dari awal dalam GNS3 untuk domain Kxx.com. Dimulai dengan penataan alamat IP, subnetting, dan konfigurasi router (Eonwe) untuk routing internal serta akses internet (NAT). Kemudian, sistem DNS yang andal dibangun menggunakan server Master (Tirion) dan Slave (Valmar), mendefinisikan berbagai record (A, CNAME, TXT, PTR) untuk semua host dan alias layanan (www, static, app, dll.). Di atas fondasi ini, dua web server backend diimplementasikan: satu statis (Lindon) dengan directory listing dan satu dinamis (Vingilot) menggunakan PHP-FPM dengan URL rewrite. Sebagai puncaknya, Sirion dikonfigurasi sebagai reverse proxy Nginx yang canggih, menangani path-based routing ke backend, menerapkan keamanan Basic Authentication untuk area admin, memastikan penggunaan URL kanonik (www) melalui redirect, meneruskan IP klien asli, dan menyajikan halaman beranda yang menghubungkan semua layanan. Pengujian beban, demonstrasi caching DNS, dan konfigurasi autostart layanan melengkapi proyek ini.






## Topologi Jaringan
<img width="628" height="573" alt="image" src="https://github.com/user-attachments/assets/48efa9de-eac8-49a1-9039-4efc3d7607ce" />










## Penjelasan tiap soal
# Penjelasan Soal 1: Alamat & Jalur
## Maksud Soal
### Definisi Asli: 
Tujuan dari soal ini adalah untuk menetapkan fondasi topologi jaringan. Ini melibatkan pemberian alamat IP statis yang unik kepada setiap komputer (node) dan mendefinisikan subnet serta gateway (gerbang keluar) untuk setiap segmen jaringan (Jalur Barat, Timur, dan DMZ).

### Penjelasan Kode
Kode ini mengkonfigurasi file /etc/network/interfaces, yang merupakan "kartu identitas" jaringan untuk setiap node.

### Konfigurasi Router (Eonwe)
```bash
# Eonwe Network Configuration

# Interface untuk Jalur Barat (ke Switch1)
auto eth1
iface eth1 inet static
  address 10.71.1.1
  netmask 255.255.255.0
... (dan seterusnya untuk eth2, eth3)
```
- auto eth1: Memberitahu sistem untuk secara otomatis mengaktifkan antarmuka jaringan (network interface) eth1 saat boot.

- iface eth1 inet static: Mengkonfigurasi eth1 untuk menggunakan alamat IP statis (alamat yang tidak akan berubah).

- address 10.71.1.1: Menetapkan alamat IP 10.71.1.1 ke antarmuka eth1. Alamat ini akan menjadi gateway atau "jalan utama blok" untuk semua node di Jalur Barat.

- netmask 255.255.255.0: Mendefinisikan ukuran subnet, yang dalam hal ini adalah 10.71.1.0/24, memungkinkan hingga 254 host di dalamnya.
  
### Konfigurasi Klien (Contoh: Earendil)
```bash
# Konfigurasi Jaringan untuk Earendil
auto eth0
iface eth0 inet static
    address 10.71.1.2
    netmask 255.255.255.0
    gateway 10.71.1.1
```
- address 10.71.1.2: Memberi Earendil "nomor rumah" uniknya.
- gateway 10.71.1.1: Ini adalah baris yang sangat penting. Ini memberitahu Earendil, "Jika kamu ingin mengirim paket ke luar blokmu (misalnya ke 10.71.2.x atau ke internet), kirimkan melalui gerbang di 10.71.1.1."

# Penjelasan Soal 2: Membuka Jalan ke Internet (NAT)
## Maksud Soal
### Definisi Asli: 
Tujuan soal ini adalah mengkonfigurasi router (Eonwe) untuk melakukan Network Address Translation (NAT). NAT adalah proses di mana router memodifikasi paket data dari jaringan internal agar seolah-olah berasal dari alamat IP publik milik router itu sendiri, sehingga memungkinkan banyak perangkat di jaringan internal untuk berbagi satu koneksi internet.

### Perumpamaan: 
Bayangkan Eonwe adalah resepsionis di sebuah kantor. Semua karyawan (node internal) memiliki nomor telepon ekstensi pribadi (IP internal). Ketika seorang karyawan ingin menelepon keluar, panggilannya disalurkan melalui resepsionis. Pihak luar hanya melihat panggilan datang dari nomor telepon utama kantor (IP publik Eonwe), bukan dari nomor ekstensi karyawan. Resepsionis kemudian secara cerdas meneruskan balasan telepon kembali ke karyawan yang tepat.

### Penjelasan Kode
Konfigurasi ini terjadi di dalam file /etc/network/interfaces milik Eonwe.
```bash
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.71.0.0/16
```
- up ...: Direktif ini berarti "jalankan perintah berikut setelah antarmuka jaringan aktif."
- iptables: Program firewall bawaan Linux yang kita gunakan untuk memanipulasi lalu lintas jaringan.
- -t nat: Menargetkan tabel NAT, yang khusus untuk tugas-tugas translasi alamat.
- -A POSTROUTING: Menambahkan (-A) aturan ini ke "rantai" POSTROUTING. Artinya, aturan ini diterapkan pada paket tepat sebelum paket tersebut meninggalkan router menuju internet.
- -o eth0: Aturan ini hanya berlaku untuk paket yang keluar (-o atau output) melalui antarmuka eth0 (jalur ke internet).
- -j MASQUERADE: Ini adalah tindakannya: "samarkan". Ganti alamat IP sumber dari paket (misalnya, 10.71.1.2 dari Earendil) dengan alamat IP publik milik eth0 Eonwe.
- -s 10.71.0.0/16: Menentukan bahwa aturan ini hanya berlaku untuk paket yang berasal (-s atau source) dari jaringan 10.71.x.x.
Selain itu, agar Eonwe dapat meneruskan paket antar antarmukanya, fitur IP Forwarding di sistem operasinya harus diaktifkan. Ini biasanya dilakukan dengan mengedit file /etc/sysctl.conf dan memastikan baris net.ipv4.ip_forward=1 aktif.

# Penjelasan Soal 3: Komunikasi Internal & Persiapan Awal
## Maksud Soal
### Definisi Asli:
Soal ini memiliki dua tujuan. Pertama, memastikan routing internal berfungsi, artinya semua klien dapat berkomunikasi satu sama lain meskipun berada di subnet yang berbeda (misalnya, Jalur Barat ke Jalur Timur). Kedua, memastikan setiap host non-router memiliki konfigurasi DNS resolver awal agar dapat mengakses repositori paket di internet menggunakan nama domain, yang penting untuk instalasi perangkat lunak.

### Perumpamaan: 
Pertama, kita memastikan pengantar surat di dalam komplek (Eonwe) bisa mengirimkan surat dari satu blok ke blok lainnya. Kedua, kita memberikan "buku telepon darurat" (DNS 192.168.122.1) kepada setiap penghuni agar mereka bisa menelepon "toko perkakas" (apt) untuk memesan alat-alat yang akan dibutuhkan nanti.

### Penjelasan
Konfigurasi ini terjadi di file /etc/network/interfaces pada semua node klien dan server.
Routing internal bukanlah hasil dari satu baris kode spesifik, melainkan hasil gabungan dari:
1. Konfigurasi gateway yang benar di setiap klien (dari Soal 1).
2. Aktivasi IP Forwarding di router Eonwe (dari Soal 2).
Dengan dua hal ini, ketika Earendil (10.71.1.2) ingin mengirim paket ke Cirdan (10.71.2.2), ia akan mengirimkannya ke gateway-nya (10.71.1.1). Eonwe kemudian akan melihat bahwa tujuan paket adalah jaringan 10.71.2.0/24 dan meneruskannya melalui antarmuka eth2.

### DNS Resolver Awal & Persiapan Alat
```bash
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt-get update
up apt-get install -y procps e2fsprogs ... nginx
```
- up echo "nameserver 192.168.122.1" > /etc/resolv.conf: Ini adalah langkah "bootstrap" yang krusial. Perintah ini secara paksa menulis alamat IP dari server DNS GNS3 (192.168.122.1) ke dalam file /etc/resolv.conf. File ini adalah "buku telepon" yang digunakan sistem untuk menerjemahkan nama domain seperti deb.debian.org menjadi alamat IP. Tanpa ini, perintah apt-get update akan gagal.

- up apt-get install -y ...: Perintah ini adalah langkah "imunisasi". Setelah node memiliki akses DNS sementara, ia langsung diperintahkan untuk mengunduh dan menginstal semua perangkat lunak (procps, e2fsprogs, bind9, nginx, dll.) yang akan kita butuhkan di soal-soal berikutnya. Tujuannya adalah untuk menghindari error command not found di kemudian hari.

### Routing Internal
Routing internal bukanlah hasil dari satu baris kode spesifik, melainkan hasil gabungan dari:
1. Konfigurasi gateway yang benar di setiap klien (dari Soal 1).
2. Aktivasi IP Forwarding di router Eonwe (dari Soal 2).
Dengan dua hal ini, ketika Earendil (10.71.1.2) ingin mengirim paket ke Cirdan (10.71.2.2), ia akan mengirimkannya ke gateway-nya (10.71.1.1). Eonwe kemudian akan melihat bahwa tujuan paket adalah jaringan 10.71.2.0/24 dan meneruskannya melalui antarmuka eth2.

### DNS Resolver Awal & Persiapan Alat
```bash
up echo "nameserver 192.168.122.1" > /etc/resolv.conf
up apt-get update
up apt-get install -y procps e2fsprogs ... nginx
```
- up echo "nameserver 192.168.122.1" > /etc/resolv.conf: Ini adalah langkah "bootstrap" yang krusial. Perintah ini secara paksa menulis alamat IP dari server DNS GNS3 (192.168.122.1) ke dalam file /etc/resolv.conf. File ini adalah "buku telepon" yang digunakan sistem untuk menerjemahkan nama domain seperti deb.debian.org menjadi alamat IP. Tanpa ini, perintah apt-get update akan gagal.

- up apt-get install -y ...: Perintah ini adalah langkah "imunisasi". Setelah node memiliki akses DNS sementara, ia langsung diperintahkan untuk mengunduh dan menginstal semua perangkat lunak (procps, e2fsprogs, bind9, nginx, dll.) yang akan kita butuhkan di soal-soal berikutnya. Tujuannya adalah untuk menghindari error command not found di kemudian hari.

# Penjelasan Soal 4: Membangun Infrastruktur DNS (Master & Slave)
## Maksud Soal
### Definisi Asli: 
Tujuan soal ini adalah menginstal perangkat lunak DNS (BIND9) dan mengkonfigurasi dua server: satu sebagai Master (sumber utama dan otoritatif untuk semua informasi domain) dan satu lagi sebagai Slave (server cadangan yang secara otomatis menyalin semua informasi dari Master). Proses penyalinan ini disebut Zone Transfer.

## Kaitan dengan Skrip
```bash
# Di dalam file K15.com.db
@       IN      NS      ns1.K15.com.
@       IN      NS      ns2.K15.com.
```
- Penjelasan: Baris NS (Name Server) ini secara resmi mendeklarasikan bahwa ns1 (Tirion) dan ns2 (Valmar) adalah server yang bertanggung jawab atas domain K15.com.
```bash
# Di dalam echo 'zone "3.71.10.in-addr.arpa" ...'
allow-transfer { 10.71.3.4; };
```
- Penjelasan: Baris allow-transfer ini adalah "surat izin" yang diberikan oleh Master (Tirion) kepada Slave (Valmar di IP 10.71.3.4) untuk memperbolehkannya menyalin semua arsip. Tanpa ini, zone transfer akan gagal.

### Tujuan: Memastikan server DNS utama (Tirion) sudah berjalan dan klien sudah menggunakannya.
- Perintah:
```bash
dig K15.com
```
- Cara Membaca Hasil:
1. Lihat bagian ANSWER SECTION. Harus melihat A record yang mengarah ke alamat IP Sirion (10.71.3.2).
2. Lihat baris paling bawah SERVER. Alamat IP di sini harus alamat IP Tirion (10.71.3.3), bukan 192.168.122.1.

# Penjelasan Soal 5: Memberi Nama dan Mendaftarkannya
## Maksud Soal
### Definisi Asli: 
Tujuan soal ini adalah mengubah hostname (nama internal sistem) di setiap node dan membuat catatan DNS tipe 'A' (A Record) untuk setiap nama tersebut. Ini memungkinkan setiap komputer di jaringan untuk ditemukan menggunakan nama domainnya (misal, earendil.K15.com), bukan hanya alamat IP.

### Penjelasan Kode
```bash
cat <<'EOF' > /etc/bind/K15/K15.com.db
...
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
lindon      IN      A       10.71.3.5
vingilot    IN      A       10.71.3.6
...
EOF
```
- cat <<'EOF' > ...: Ini adalah perintah shell yang kuat untuk menimpa seluruh isi file /etc/bind/K15/K15.com.db dengan blok teks yang ada di antara <<'EOF' dan EOF.
- Blok A RECORDS: Bagian ini adalah implementasi langsung dari soal 5. Setiap baris adalah sebuah A Record yang secara resmi mendaftarkan sebuah nama ke sebuah alamat IP.
- earendil IN A 10.71.1.2: Baris ini berarti: "Catat bahwa nama earendil (dalam domain K15.com) memiliki alamat (A) IPv4 10.71.1.2."

### Tujuan: Memastikan semua nama host baru telah berhasil didaftarkan di server DNS.
- Perintah: Uji beberapa nama host baru dari subnet yang berbeda.
```bash
dig vingilot.K15.com
dig elrond.K15.com
```
- Cara Membaca Hasil:
1. Untuk dig vingilot.K15.com, ANSWER SECTION harus menunjukkan alamat IP Vingilot (10.71.3.6).
2. Untuk dig elrond.K15.com, ANSWER SECTION harus menunjukkan alamat IP Elrond (10.71.2.3).

# Penjelasan Soal 6: Verifikasi Sinkronisasi (Zone Transfer)
## Maksud Soal
### Definisi Asli: 
Tujuan soal ini adalah untuk memverifikasi bahwa proses Zone Transfer dari Master ke Slave berjalan dengan benar. Ini dibuktikan dengan memeriksa bahwa Nomor Serial SOA (Start of Authority) di kedua server identik. Nomor serial ini adalah sebuah angka yang harus dinaikkan oleh administrator setiap kali ada perubahan pada file zona, yang bertindak sebagai penanda versi.

### Kaitan dengan Skrip
```bash
...
@       IN      SOA     ns1.K15.com. root.K15.com. (
                    2025101301      ; Serial
```
- Penjelasan: Dengan menuliskan nomor serial 2025101301, skrip ini menetapkan "nomor versi" dari data zona. Ketika memverifikasi (misalnya dengan perintah dig soa K15.com), akan membandingkan nomor ini di Tirion dan Valmar. Fakta bahwa harus menaikkan nomor ini setiap kali mengedit adalah inti dari mekanisme zone transfer.

### Tujuan: Memastikan server DNS cadangan (Valmar) memiliki data yang sama persis dengan server utama (Tirion).
- Perintah: Bandingkan nomor serial dari kedua server.
1. Cek nomor serial di Master (Tirion):
```bash
dig soa K15.com
```
2. Cek nomor serial di Slave (Valmar):
```bash
dig @10.71.3.4 soa K15.com
```
- Cara Membaca Hasil:
- Lihat angka panjang setelah nama root.K15.com. di ANSWER SECTION pada kedua output. Kedua angka serial tersebut harus sama persis (contoh: 2025101301).

# Penjelasan Soal 7: Membuat Alias Layanan (CNAME)
## Maksud Soal
### Definisi Asli: 
Tujuan soal ini adalah membuat catatan DNS tipe 'CNAME' (Canonical Name). CNAME berfungsi sebagai alias, mengarahkan satu nama domain ke nama domain lain yang sudah ada. Ini berguna untuk membuat nama yang lebih mudah diingat atau untuk mengarahkan beberapa layanan ke server yang sama.

## Penjelasan Kode
```bash
...
;
; CNAME RECORDS (SOAL 7)
www         IN      CNAME   sirion.K15.com.
static      IN      CNAME   lindon.K15.com.
app         IN      CNAME   vingilot.K15.com.
...
```
- Blok CNAME RECORDS: Bagian ini membuat tiga buah alias.
- www IN CNAME sirion.K15.com.: Baris ini berarti: "Catat bahwa nama www (dalam domain K15.com) adalah sebuah alias (CNAME) untuk nama kanonik sirion.K15.com."
- Tanda Titik (.) di Akhir: Tanda titik di akhir nama tujuan (sirion.K15.com.) sangat krusial. Ini menandakan bahwa nama tersebut adalah FQDN (Fully-Qualified Domain Name) atau nama yang sudah lengkap. Tanpa titik, BIND9 akan secara otomatis menambahkan nama domain asal di belakangnya, menjadi sirion.K15.com.K15.com, yang akan menyebabkan error.

### Tujuan: Memastikan nama panggilan seperti www berfungsi dan mengarah ke nama host yang benar.
- Perintah:
```bash
dig www.K15.com
```
- Cara Membaca Hasil:
- ANSWER SECTION harus menampilkan dua baris:
1. Satu baris CNAME yang menunjukkan bahwa www.K15.com. adalah alias dari sirion.K15.com..
2. Satu baris A yang menunjukkan bahwa sirion.K15.com. memiliki alamat IP 10.71.3.2.

# Penjelasan Soal 8: Membuat Peta Terbalik (Reverse DNS)
## Maksud Soal
### Definisi Asli: 
Tujuan soal ini adalah mengkonfigurasi Reverse DNS zone. Ini adalah proses kebalikan dari DNS biasa, yaitu memetakan sebuah alamat IP kembali ke nama domainnya menggunakan catatan 'PTR' (Pointer). Ini sering digunakan untuk verifikasi keamanan dan pelacakan log.
## Penjelasan Kode
```bash
# Menambahkan konfigurasi Reverse DNS (Soal 8)
echo 'zone "3.71.10.in-addr.arpa" { ... };' >> /etc/bind/named.conf.local

cat <<'EOF' > /etc/bind/K15/rev.3.71.10.db
...
;
; PTR Records for DMZ Hosts
2       IN      PTR     sirion.K15.com.
5       IN      PTR     lindon.K15.com.
6       IN      PTR     vingilot.K15.com.
EOF

echo ">>> Memperbaiki izin file lagi untuk file baru..."
chown bind:bind /etc/bind/K15/rev.3.71.10.db
```
- echo 'zone "3.71.10.in-addr.arpa" ...' >> ...: Perintah ini menambahkan (>>) deklarasi zona baru ke file konfigurasi utama BIND9.
- 3.71.10.in-addr.arpa: Ini adalah nama standar untuk Reverse Zone. Ia dibentuk dengan mengambil 3 oktet pertama dari subnet (10.71.3), membaliknya (3.71.10), dan menambahkan akhiran .in-addr.arpa.
- cat <<'EOF' > /etc/bind/K15/rev.3.71.10.db: Perintah ini membuat file "buku telepon terbalik" itu sendiri.
- 2 IN PTR sirion.K15.com.: Ini adalah sebuah PTR Record. Ini berarti: "Alamat IP di dalam zona ini yang berakhiran .2 (yaitu 10.71.3.2) adalah milik (PTR) nama sirion.K15.com."
- chown bind:bind ...: Ini adalah langkah troubleshooting penting yang ditemukan. Perintah ini mengubah kepemilikan file baru (rev.3.71.10.db) dari root menjadi bind. Ini diperlukan agar layanan BIND9, yang berjalan sebagai user bind, memiliki izin untuk membaca file tersebut. Tanpa ini, akan terjadi error permission denied atau SERVFAIL.

### Tujuan: Memastikan pencarian alamat IP ke nama host berfungsi dengan benar.
- Perintah: Gunakan flag -x (untuk reverse lookup) pada salah satu IP di segmen DMZ.
```bash
dig -x 10.71.3.5
```
- Cara Membaca Hasil:
- ANSWER SECTION harus berisi satu baris PTR record yang menyatakan bahwa alamat IP 10.71.3.5 adalah milik lindon.K15.com..
- Di bagian flags pada header, juga akan melihat flag aa (Authoritative Answer), yang menandakan jawaban ini resmi.

# Penjelasan Soal 9: Menjalankan Web Server Statis (Lampion Lindon)
## Maksud Soal
### Definisi Asli:
Tujuan dari soal ini adalah untuk menginstal dan mengkonfigurasi perangkat lunak web server Nginx di node Lindon. Server ini dikonfigurasi untuk menyajikan konten statis (file HTML dan teks biasa) saat diakses melalui hostname static.K15.com. Selain itu, untuk path URL /annals/, server harus mengaktifkan fitur autoindex, yang berfungsi untuk menampilkan daftar file di dalam direktori tersebut, bukan mencari file index.html.
## Cara Memastikan Keberhasilan
Untuk memastikan soal ini berhasil, perlu melakukan verifikasi dari terminal klien (misalnya, Earendil):
1. Verifikasi Halaman Utama: Jalankan perintah lynx untuk mengakses halaman utama.
```bash
lynx http://static.K15.com
```
Harus melihat konten dari file index.html ("Selamat Datang di Pelabuhan Statis Lindon").

2. Verifikasi Autoindex: Jalankan lynx untuk mengakses direktori /annals/.
```bash
lynx http://static.K15.com/annals/
```
Anda harus melihat daftar file yang berisi catatan_kuno.txt, bukan halaman web. Ini membuktikan autoindex aktif.

## Penjelasan Kode
Skrip setup_lindon_web.sh ini dirancang untuk mengotomatisasi seluruh proses penyiapan web server statis di Lindon.

### 1. Membuat Konten Web 
```bash
#!/bin/bash
set -e
echo ">>> Membuat konten web..."
mkdir -p /var/www/static.K15.com/annals
echo "<h1>Selamat Datang di Pelabuhan Statis Lindon</h1>" > /var/www/static.K15.com/index.html
echo "Ini adalah catatan dari Zaman Pertama." > /var/www/static.K15.com/annals/catatan_kuno.txt
```
- set -e: Memastikan skrip akan berhenti jika ada perintah yang gagal, mencegah konfigurasi yang salah.
- mkdir -p /var/www/static.K15.com/annals: Membuat struktur direktori untuk menyimpan file website. Opsi -p membuat direktori induk (/var/www/static.K15.com) jika belum ada.
- echo "<h1>..." > .../index.html: Membuat file halaman utama (index.html) di direktori root situs dan mengisinya dengan kode HTML sederhana. Simbol > menimpa file jika sudah ada.
- echo "Ini adalah..." > .../catatan_kuno.txt: Membuat file teks (catatan_kuno.txt) di dalam direktori /annals/ sebagai contoh konten yang akan ditampilkan oleh autoindex.

### 2. Membuat File Konfigurasi Nginx 
```bash
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
```
- cat <<'EOF' > ...: Menulis blok teks multi-baris ke dalam file konfigurasi Nginx /etc/nginx/sites-available/static.K15.com. File ini berisi instruksi spesifik untuk Nginx tentang cara menyajikan situs static.K15.com.
- server { ... }: Mendefinisikan server block, yaitu satu set konfigurasi untuk satu situs web virtual.
- listen 80;: Memberitahu Nginx untuk mendengarkan koneksi masuk pada port 80 (port standar HTTP).
- root /var/www/static.K15.com;: Menentukan direktori akar (root directory) tempat Nginx akan mencari file-file untuk situs ini. Ini sesuai dengan direktori yang dibuat pada langkah sebelumnya.
- index index.html;: Jika klien meminta direktori (misalnya, http://static.K15.com/), Nginx akan mencoba menyajikan file index.html dari direktori tersebut.
- server_name static.K15.com;: Menginstruksikan Nginx bahwa konfigurasi server block ini hanya berlaku untuk permintaan yang ditujukan ke hostname static.K15.com.
- location /annals/ { autoindex on; }: Mendefinisikan aturan khusus untuk URL yang dimulai dengan /annals/.
  - autoindex on;: Direktif kunci yang mengaktifkan fitur directory listing. Nginx akan menampilkan daftar file di dalam direktori /var/www/static.K15.com/annals/ alih-alih mencari file index.html.

### 3. Mengaktifkan Situs dan Membuatnya Permanen 
```bash
echo ">>> Mengaktifkan situs dan membuatnya permanen..."
ln -sfn /etc/nginx/sites-available/static.K15.com /etc/nginx/sites-enabled/static.K15.com
rm -f /etc/nginx/sites-enabled/default
service nginx restart
update-rc.d nginx defaults
```
- ln -sfn ...: Perintah ini mengaktifkan situs. Nginx memuat konfigurasi dari direktori /etc/nginx/sites-enabled/. Perintah ini membuat symbolic link (pintasan) dari file konfigurasi yang kita buat (sites-available) ke direktori aktif (sites-enabled). Opsi -f memastikan link lama ditimpa jika ada, dan -n mencegah link mengikuti target jika targetnya adalah direktori.
- rm -f /etc/nginx/sites-enabled/default: Menghapus link konfigurasi situs default Nginx. Ini penting untuk mencegah konflik dengan situs baru kita.
- service nginx restart: Menerapkan semua perubahan konfigurasi dengan me-restart layanan Nginx.
- update-rc.d nginx defaults: Mengatur agar layanan nginx secara otomatis dimulai setiap kali node Lindon di-boot. Ini membuat layanan menjadi persisten.

# Penjelasan Soal 10: Menjalankan Web Server Dinamis (Kisah Vingilot)
## Maksud Soal
### Definisi Asli:
Tujuan soal ini adalah mengkonfigurasi node Vingilot untuk menjalankan sebuah web server dinamis. Ini melibatkan instalasi Nginx sebagai web server dan PHP-FPM (FastCGI Process Manager) sebagai engine untuk mengeksekusi kode PHP. Server harus dapat diakses melalui hostname app.K15.com dan menyajikan halaman utama (index.php) serta halaman about.php. Selain itu, harus diterapkan URL Rewrite sehingga halaman about dapat diakses melalui URL http://app.K15.com/about (tanpa ekstensi .php).

## Cara Memastikan Keberhasilan
Untuk memastikan soal ini berhasil, perlu melakukan verifikasi dari terminal klien (misalnya, Earendil):
1. Verifikasi Halaman Utama: Jalankan lynx untuk mengakses beranda.
```bash
lynx http://app.K15.com
```
Anda harus melihat output dari skrip index.php ("Vingilot Mengisahkan Cerita Dinamis!").
2. Verifikasi URL Rewrite: Jalankan lynx untuk mengakses path /about tanpa .php.

```bash
lynx http://app.K15.com/about
```
Anda harus melihat output dari skrip about.php ("Ini adalah halaman About dari Vingilot.").

## Penjelasan Kode
Skrip ini (atau rangkaian perintah yang Anda jalankan) mengotomatisasi seluruh proses penyiapan web server dinamis di Vingilot.

1. Instalasi Perangkat Lunak 
```bash
apt-get update
apt-get install -y nginx php8.4-fpm
```
- apt-get update: Memperbarui daftar paket perangkat lunak yang tersedia dari repositori.
- apt-get install -y nginx php8.4-fpm: Menginstal dua paket utama:
  - nginx: Perangkat lunak web server yang akan menerima permintaan dari klien.
  - php8.4-fpm: Mesin PHP (FastCGI Process Manager) yang akan mengeksekusi kode PHP. Nginx akan berkomunikasi dengan proses ini untuk menghasilkan konten dinamis. Opsi -y otomatis menjawab "yes" untuk konfirmasi instalasi. (Jika versi 8.4 tidak tersedia, php-fpm akan menginstal versi default).

2. Membuat Konten Web Dinamis 
```bash
mkdir -p /var/www/app.K15.com
echo "<h1>Vingilot Mengisahkan Cerita Dinamis!</h1><p>Ini adalah halaman beranda.</p>" > /var/www/app.K15.com/index.php
echo "<h2>Ini adalah halaman About dari Vingilot.</h2>" > /var/www/app.K15.com/about.php
```
- mkdir -p /var/www/app.K15.com: Membuat direktori root untuk situs web app.K15.com.
- echo "<h1>..." > .../index.php: Membuat file halaman utama (index.php) yang berisi kode HTML sederhana. Meskipun ini HTML, karena disimpan sebagai .php, Nginx akan tetap meneruskannya ke PHP-FPM untuk diproses.
- echo "<h2>..." > .../about.php: Membuat file about.php yang akan menjadi target dari URL Rewrite.
## 3. Membuat File Konfigurasi Nginx 
```bash
nano /etc/nginx/sites-available/app.K15.com
# didalamnya:
server {
    listen 80;
    root /var/www/app.K15.com;
    index index.php;
    server_name app.K15.com;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    location = /about {
        try_files $uri /about.php;
    }
}
```
- nano ...: Membuka editor teks untuk membuat file konfigurasi Nginx yang spesifik untuk situs app.K15.com.
- server { ... }: Mendefinisikan server block untuk situs ini.
- listen 80;, root ...;, index index.php;, server_name app.K15.com;: Direktif dasar yang sama seperti pada Soal 9, tetapi index sekarang menunjuk ke file PHP.
- location / { try_files $uri $uri/ /index.php?$query_string; }: Blok ini menangani permintaan umum. try_files adalah direktif penting:
1. Ia mencoba mencari file yang persis sama dengan URL ($uri).
2. Jika tidak ada, ia mencoba mencari direktori yang sama ($uri/).
3. Jika keduanya gagal, ia akan secara internal mengarahkan permintaan ke /index.php sambil membawa parameter query asli (?$query_string). Ini adalah pola umum untuk aplikasi PHP modern (framework).
- location ~ \.php$ { ... }: Blok ini secara spesifik menangani URL yang diakhiri dengan .php.
  - include snippets/fastcgi-php.conf;: Memuat konfigurasi standar untuk meneruskan parameter ke PHP-FPM.
  - fastcgi_pass unix:/run/php/php8.4-fpm.sock;: Perintah Kunci. Ini memberitahu Nginx untuk meneruskan permintaan eksekusi PHP ke proses PHP-FPM yang "mendengarkan" di alamat socket tersebut. Pastikan path socket ini sesuai dengan versi PHP-FPM yang terinstal.

- location = /about { try_files $uri /about.php; }: Ini adalah implementasi URL Rewrite.
  - location = /about: Tanda = berarti hanya cocok persis dengan URL /about.
  - try_files $uri /about.php;: Nginx akan mencoba mencari file bernama /about. Karena tidak ada, ia akan langsung mencoba alternatif kedua, yaitu secara internal menyajikan file /about.php, tanpa mengubah URL yang dilihat oleh pengguna.

4. Mengaktifkan Layanan dan Situs 
```bash
# jalankan php-fpm
service php8.4-fpm start
# Buat agar otomatis menyala saat boot
update-rc.d php8.4-fpm defaults
# (Perintah Nginx dari skrip sebelumnya, seperti ln -sfn ..., rm ..., service nginx restart, update-rc.d ...)
```
- service php8.4-fpm start: Menjalankan layanan PHP-FPM. Tanpa ini, Nginx tidak akan punya "aktor" untuk mengeksekusi kode PHP.
- update-rc.d php8.4-fpm defaults: Mengatur agar layanan PHP-FPM otomatis berjalan saat boot.
- Perintah Nginx (dari skrip sebelumnya): Langkah-langkah ini (membuat symlink, menghapus default, me-restart nginx, dan mengaktifkan autostart) adalah prosedur standar untuk mengaktifkan situs baru di Nginx dan membuatnya permanen.

# Penjelasan Soal 11: Konfigurasi Reverse Proxy (Sirion sebagai Muara Sungai)
## Maksud Soal
### Definisi Asli:
Tujuan soal ini adalah mengkonfigurasi Nginx di node Sirion agar berfungsi sebagai Reverse Proxy. Ia harus menerapkan path-based routing: semua permintaan yang URL-nya diawali dengan /static harus diteruskan ke server Lindon, dan semua permintaan yang diawali /app harus diteruskan ke server Vingilot. Saat meneruskan permintaan tersebut, Nginx di Sirion juga harus menyertakan header HTTP tambahan (Host dan X-Real-IP) yang berisi informasi klien asli. Selain itu, Sirion harus dikonfigurasi untuk merespons permintaan yang ditujukan ke hostname www.K15.com (nama kanonik) dan sirion.K15.com.

## Cara Memastikan Keberhasilan
Untuk memastikan soal ini berhasil, perlu melakukan verifikasi dari terminal klien (misalnya, Earendil):
1. Verifikasi Rute Statis via www: Jalankan lynx untuk mengakses path /static/ melalui www.
```bash
lynx http://www.K15.com/static/
```
Harus melihat konten dari Lindon ("Selamat Datang di Pelabuhan Statis Lindon").
2. Verifikasi Rute Dinamis via www: Jalankan lynx untuk mengakses path /app/ melalui www.
```bash
lynx http://www.K15.com/app/
```
Harus melihat konten dari Vingilot ("Vingilot Mengisahkan Cerita Dinamis!").
3. Verifikasi Akses via sirion: Ulangi salah satu tes di atas, tetapi gunakan nama sirion.K15.com.
```bash
lynx http://sirion.K15.com/static/
```
Harus mendapatkan hasil yang sama seperti tes pertama, membuktikan bahwa Sirion juga merespons nama sirion.K15.com.

## Penjelasan Kode
Rangkaian perintah ini mengkonfigurasi Nginx di Sirion sebagai reverse proxy.
### 1. Membuat File Konfigurasi Nginx 
```bash
nano /etc/nginx/sites-available/reverse-proxy.conf
# isi konfigurasi:
server {
    listen 80;
    server_name www.K15.com sirion.K15.com;

    location /static/ {
        proxy_pass http://lindon.K15.com/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /app/ {
        proxy_pass http://app.K15.com/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```
- nano ...: Membuka editor teks untuk membuat file konfigurasi Nginx /etc/nginx/sites-available/reverse-proxy.conf. File ini berisi instruksi spesifik untuk Nginx tentang bagaimana ia harus bertindak sebagai reverse proxy.
- server { ... }: Mendefinisikan server block, satu set konfigurasi untuk situs virtual ini.
- listen 80;: Memberitahu Nginx untuk mendengarkan koneksi masuk pada port 80 (HTTP).
- server_name www.K15.com sirion.K15.com;: Menginstruksikan Nginx bahwa konfigurasi ini berlaku untuk permintaan yang ditujukan ke hostname www.K15.com atau sirion.K15.com.
- location /static/ { ... }: Mendefinisikan aturan untuk URL yang dimulai dengan /static/.
  - proxy_pass http://lindon.K15.com/;: Perintah Kunci. Ini memberitahu Nginx untuk mengambil permintaan klien dan meneruskannya (proxy_pass) ke server backend yang beralamat di http://lindon.K15.com/. Tanda / di akhir URL backend penting untuk pemetaan path.
  - proxy_set_header Host $host;: Meneruskan header Host asli dari klien ke server backend. $host adalah variabel Nginx yang berisi nama domain yang diminta klien (misalnya, www.K15.com). Ini penting agar backend tahu situs mana yang diminta jika ia melayani banyak domain.
  - proxy_set_header X-Real-IP $remote_addr;: Membuat header kustom X-Real-IP dan mengisinya dengan alamat IP asli klien ($remote_addr). Ini memungkinkan server backend (Lindon/Vingilot) untuk mencatat IP pengunjung asli di log mereka, bukan hanya IP Sirion.
- location /app/ { ... }: Mendefinisikan aturan serupa untuk URL yang dimulai dengan /app/, tetapi meneruskan permintaan (proxy_pass) ke server backend http://app.K15.com/ (Vingilot). Header Host dan X-Real-IP juga diteruskan.

2. Mengaktifkan Situs dan Membuatnya Permanen 🚀
```bash
ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
service nginx restart
update-rc.d nginx defaults
```
- ln -s ...: Mengaktifkan konfigurasi reverse proxy dengan membuat symbolic link dari direktori sites-available ke direktori sites-enabled yang dibaca Nginx saat start.
- rm /etc/nginx/sites-enabled/default: Menghapus link konfigurasi situs default Nginx untuk mencegah konflik.
- service nginx restart: Menerapkan semua perubahan dengan me-restart layanan Nginx.
- update-rc.d nginx defaults: Mengatur agar layanan nginx di Sirion secara otomatis dimulai setiap kali node di-boot.

# Penjelasan Soal 12: Melindungi Area Admin (Basic Auth)
## Maksud Soal
### Definisi Asli:
Tujuan soal ini adalah untuk menambahkan lapisan keamanan pada reverse proxy di Sirion. Path URL /admin/ harus dilindungi menggunakan Basic HTTP Authentication, sebuah mekanisme standar di mana server akan meminta username dan password melalui jendela pop-up di browser sebelum mengizinkan akses ke sumber daya tersebut. Akses tanpa kredensial yang valid harus ditolak (biasanya dengan kode status 401 Unauthorized).
## Cara Memastikan Keberhasilan
Untuk memastikan soal ini berhasil, Anda perlu melakukan verifikasi dari terminal klien (misalnya, Earendil):
1. Verifikasi Akses Tanpa Kredensial (Harus Ditolak): Jalankan lynx untuk mencoba mengakses /admin/ secara langsung.
```bash
lynx http://www.K15.com/admin/
```
Anda harus mendapatkan pesan error 401 Unauthorized atau ditolak aksesnya.
2. Verifikasi Akses dengan Kredensial Benar (Harus Berhasil): Jalankan lynx lagi, kali ini dengan flag -auth untuk memberikan username admin dan password admin123.
```bash
lynx -auth=admin:admin123 http://www.K15.com/admin/
```
Harus berhasil masuk dan melihat konten yang dilindungi (misalnya, "Selamat Datang, Admin!").

## Penjelasan Kode
Rangkaian Perintahini mengkonfigurasi Nginx di Sirion untuk melindungi path /admin/ menggunakan Basic Auth.

### 1. Instalasi Alat Pembuat Kata Sandi 
```bash
apt-get install -y apache2-utils
```
apt-get install -y apache2-utils: Perintah ini menginstal paket apache2-utils. Paket ini berisi berbagai utilitas pendukung untuk web server Apache, namun salah satu utilitasnya, yaitu htpasswd, sangat berguna dan umum digunakan untuk membuat file username dan password terenkripsi yang dibutuhkan oleh Nginx untuk Basic Auth.

### 2. Membuat File Pengguna dan Kata Sandi ("Buku Tamu") 
```bash
htpasswd -cb /etc/nginx/.htpasswd admin admin123
```
- htpasswd: Nama program yang digunakan untuk mengelola file kata sandi Basic Auth.
- -c: Opsi Create. Memberitahu htpasswd untuk membuat file baru. Opsi ini hanya boleh digunakan saat pertama kali membuat file dan menambahkan pengguna pertama. Jika file sudah ada dan Anda ingin menambah pengguna lain, jangan gunakan -c.
- -b: Opsi Batch mode. Memungkinkan Anda untuk memberikan kata sandi langsung di baris perintah. Tanpa -b, htpasswd akan meminta Anda mengetik kata sandi secara interaktif.
- /etc/nginx/.htpasswd: Lokasi dan nama file tempat menyimpan username dan password terenkripsi. Lokasi ini umum digunakan, tetapi bisa diubah sesuai kebutuhan.
- admin: Username yang dibuat.
- admin123: Password untuk username admin. htpasswd akan mengenkripsi password ini sebelum menyimpannya ke dalam file.
### 3. Memperbarui File Konfigurasi Nginx (Memberi Instruksi pada "Penjaga") 
```bash
# /etc/nginx/sites-available/sirion.conf
server {
    listen 80 default_server;
    server_name www.K15.com sirion.K15.com;

    # Blok untuk melindungi /admin
    location /admin/ {
        auth_basic "Area Terlarang! Masukkan Kredensial!";
        auth_basic_user_file /etc/nginx/.htpasswd;
        alias /var/www/html/;
    }
    # ... blok location lain ...
}
```
- location /admin/ { ... }: Blok ini mendefinisikan aturan khusus hanya untuk URL yang dimulai dengan /admin/.
- auth_basic "Area Terlarang! Masukkan Kredensial!";: Direktif Kunci. Ini mengaktifkan mekanisme Basic Authentication untuk lokasi ini. Teks di dalam tanda kutip ("Area Terlarang!...") adalah pesan "realm" yang akan ditampilkan oleh browser di jendela pop-up login.
- auth_basic_user_file /etc/nginx/.htpasswd;: Direktif Kunci. Ini memberitahu Nginx di mana harus mencari file yang berisi daftar username dan password yang valid (.htpasswd yang baru saja kita buat).
- alias /var/www/html/;: Direktif ini (yang merupakan hasil troubleshooting kita sebelumnya) memberitahu Nginx bahwa setelah autentikasi berhasil, konten yang harus disajikan untuk URL /admin/ sebenarnya berada di direktori /var/www/html/.
### 4. Memperbaiki Izin Akses ("Memberi Kunci" pada "Penjaga") 
```bash
chmod 755 /etc/nginx
chown www-data:www-data /etc/nginx/.htpasswd
chmod 640 /etc/nginx/.htpasswd
```
- chmod 755 /etc/nginx: (Hasil troubleshooting) Mengatur izin pada direktori /etc/nginx agar proses Nginx (yang biasanya berjalan sebagai user www-data) dapat "masuk" ke dalamnya untuk membaca file konfigurasi dan file .htpasswd.
- chown www-data:www-data /etc/nginx/.htpasswd: Mengubah kepemilikan file .htpasswd dari root (yang membuatnya) menjadi www-data (user yang menjalankan Nginx). Ini sangat penting agar proses Nginx memiliki izin untuk membaca file kata sandi.
- chmod 640 /etc/nginx/.htpasswd: Mengatur izin file kata sandi. 640 (rw-r-----) berarti pemilik (www-data) bisa membaca/menulis, grup (www-data) bisa membaca, dan pengguna lain tidak bisa mengakses sama sekali. Ini adalah pengaturan izin yang aman.

### 5. Mengaktifkan Konfigurasi dan Restart Penuh 
```bash
ln -s /etc/nginx/sites-available/sirion.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
service nginx stop
killall nginx || true
service nginx start
```
- ln -s ...: Mengaktifkan konfigurasi sirion.conf dengan membuat symlink di direktori sites-enabled.
- rm -f ...: Menghapus konfigurasi default untuk mencegah konflik.
- service nginx stop; killall nginx || true; service nginx start: Ini adalah metode restart paksa (hasil troubleshooting kita). Ini memastikan semua proses Nginx lama benar-benar dihentikan sebelum memulai yang baru, memaksa Nginx untuk membaca konfigurasi yang paling baru dan bersih.


>> Ganti `<KXX.com>` dengan *hostname* domain yang sebenarnya `K15.com`

### 13\. Pengalihan Wajib $ \text{Hostname}$ ($ \text{Sirion}$)

**Tujuan:** Memastikan semua akses ke **Sirion** yang menggunakan IP Address atau *hostname* non-kanonik (`sirion.<KXX.com>`) dialihkan secara permanen (*redirect* 301) ke *hostname* kanonik `www.<KXX.com>`.

**Hasil Pengerjaan:**

  * **Aksi:** Menambahkan blok `server` baru di Nginx **Sirion** yang diatur sebagai `default_server`. Blok ini secara eksplisit menangani semua permintaan yang tidak cocok dengan *hostname* utama (`www.<KXX.com>`) dan menjalankan pengalihan 301.
  * **Perubahan Konfigurasi Nginx (Sirion):**
    ```nginx
    # /etc/nginx/sites-available/sirion.conf
    server {
        # 'default_server' menangani permintaan yang tidak cocok (termasuk akses via IP)
        listen 80 default_server;
        
        # Juga secara eksplisit menangani nama 'sirion'
        server_name sirion.<KXX.com>;

        # Pengalihan permanen (301) ke nama kanonik www.<KXX.com>
        # Variabel $request_uri memastikan path asli dipertahankan (misal /static/)
        return 301 http://www.<KXX.com>$request_uri;
    }
    ```
  * **Verifikasi:** Mengakses Sirion menggunakan IP Address atau `sirion.<KXX.com>` akan menghasilkan kode respons **301 Moved Permanently** yang secara otomatis mengarahkan ke `www.<KXX.com>`.

### 14\. Pencatatan IP Klien Asli ($ \text{Vingilot}$)

**Tujuan:** Memastikan *access log* di **Vingilot** (web dinamis) mencatat IP klien asli, bukan IP *Reverse Proxy* **Sirion**.

**Hasil Pengerjaan:**

  * **Aksi:** Mengubah konfigurasi Nginx di **Vingilot** untuk menggunakan format *log* baru bernama `proxy`. Format ini secara eksplisit menggunakan variabel `$http\_x\_real\_ip` yang nilainya diteruskan oleh **Sirion** melalui *header* `X-Real-IP`.
  * **Perubahan Konfigurasi Nginx (Vingilot):**
    ```nginx
    # /etc/nginx/nginx.conf
    log_format proxy '$http_x_real_ip - $remote_user [$time_local] '
                     '"$request" $status $body_bytes_sent '
                     '"$http_referer" "$http_user_agent"';

    # Blok server app.<KXX.com>
    access_log /var/log/nginx/access.log proxy;
    ```
  * **Verifikasi:** Setelah diakses dari klien (misalnya **Earendil**), *access log* di Vingilot menunjukkan IP Address Earendil (`10.71.1.2`), bukan IP Sirion.

### 15\. Pengujian Kinerja ($ \text{ApacheBench}$)

**Tujuan:** Mengukur perbedaan kinerja antara layanan statis (**Lindon**) dan layanan dinamis (**Vingilot**) melalui *Reverse Proxy* **Sirion** menggunakan `ab`.

**Hasil Pengerjaan:**

  * **Aksi:** Menjalankan **ApacheBench** (`ab -n 500 -c 10`) dari klien **Elrond** untuk kedua *endpoint*.
      * Layanan Dinamis: `ab -n 500 -c 10 http://www.<KXX.com>/app/`
      * Layanan Statis: `ab -n 500 -c 10 http://www.<KXX.com>/static/`
  * **Analisis:** Layanan statis (`/static/`) menunjukkan nilai **Requests per second** (RPS) yang secara signifikan **lebih tinggi** dibandingkan layanan dinamis (`/app/`). Hal ini mengonfirmasi bahwa pemrosesan PHP-FPM pada layanan dinamis membutuhkan *overhead* yang lebih besar dibandingkan penyajian file statis, meskipun keduanya melalui *reverse proxy* yang sama.

### 16\. Simulasi Perubahan Data DNS dengan $ \text{TTL}$ Pendek

**Tujuan:** Mensimulasikan perubahan IP pada *A record* **lindon** dengan $ \text{TTL}=30$ detik untuk mengamati proses *caching* DNS.

**Hasil Pengerjaan:**

  * **Aksi:** Mengubah IP **lindon** (misalnya ke `10.71.3.50`) dan menaikkan **$ \text{Serial SOA}$** pada file zona di **Tirion**. *TTL* *record* `lindon.<KXX.com>` dan `static.<KXX.com>` ditetapkan menjadi `30` detik.
  * **Perubahan File Zona (Tirion):**
    ```dns
    @       IN      SOA     ... ( 2025101304 ; Serial NAIK )
    ...
    lindon      30      IN      A       10.71.3.50  ; <-- UBAH IP & TTL
    ...
    static      30      IN      CNAME   lindon.<KXX.com>. ; <-- TAMBAHKAN TTL
    ```
  * **Verifikasi:**
    1.  **Momen 1 (Sebelum Perubahan):** `dig` menunjukkan IP lama.
    2.  **Momen 2 (Setelah Perubahan, $ \text{TTL}$ Belum Kedaluwarsa):** `dig` di klien masih menunjukkan IP lama karena *cache* lokal belum habis.
    3.  **Momen 3 (Setelah $ \text{TTL}=30$ Detik Kedaluwarsa):** `dig` di klien menunjukkan IP baru (`10.71.3.50`), membuktikan bahwa *caching* berhasil diperbarui.

### 17\. $ \text{Autostart}$ Layanan Inti

**Tujuan:** Memastikan semua layanan inti (`bind9`, `nginx`, `php8.4-fpm`) dapat memulai secara otomatis saat *reboot* menggunakan `update-rc.d`.

**Hasil Pengerjaan:**

  * **Aksi:** Menjalankan perintah `update-rc.d <layanan> defaults` di *node* yang bersangkutan.
      * **Tirion/Valmar:** `update-rc.d named defaults`
      * **Sirion/Lindon:** `update-rc.d nginx defaults`
      * **Vingilot:** `update-rc.d php8.4-fpm defaults`
  * **Tambahan (Tirion):** Untuk mengatasi masalah *resolver* setelah *reboot*, file `/etc/resolv.conf` dibuka kuncinya (`chattr -i`), layanan `named` distart, dan dikunci kembali (`chattr +i`).
  * **Verifikasi:** Setelah *reboot* simulasi, status layanan (misalnya `service named status`) menunjukkan layanan berjalan otomatis.

### 18\. $ \text{TXT}$ dan $ \text{CNAME}$ untuk Melkor/Morgoth

**Tujuan:** Menambahkan *TXT record* untuk **melkor** dan *CNAME record* **morgoth** yang menunjuk ke **melkor**.

**Hasil Pengerjaan:**

  * **Aksi:** Menaikkan **$ \text{Serial SOA}$** dan menambahkan *record* di file zona **Tirion**.
  * **Perubahan File Zona (Tirion):**
    ```dns
    @       IN      SOA     ... ( 2025101306 ; Serial NAIK )
    ...
    melkor      IN      TXT     "Morgoth (Melkor)"
    morgoth     IN      CNAME   melkor.<KXX.com>.
    ```
  * **Verifikasi:**
      * `dig melkor.<KXX.com> TXT` berhasil menampilkan nilai `“Morgoth (Melkor)”`.
      * `dig morgoth.<KXX.com>` berhasil me-*resolve* dan mengikuti alias **melkor**, yang kemudian me-*resolve* IP dari **melkor** (jika `melkor` memiliki *A record*).

### 19\. $ \text{CNAME}$ Tambahan ($ \text{havens}$)

**Tujuan:** Menambahkan *CNAME record* **havens.**\<xxxx\>**.$ \text{com}$** sebagai alias dari *hostname* kanonik **www.**\<xxxx\>**.$ \text{com}$**.

**Hasil Pengerjaan:**

  * **Aksi:** Menaikkan **$ \text{Serial SOA}$** dan menambahkan *CNAME* **havens** di file zona **Tirion**.
  * **Perubahan File Zona (Tirion):**
    ```dns
    @       IN      SOA     ... ( 2025101307 ; Serial NAIK )
    ...
    havens      IN      CNAME   www.<KXX.com>.
    ```
  * **Verifikasi:** `dig havens.<KXX.com>` me-*resolve* IP yang sama dengan `www.<KXX.com>`. Akses web (`lynx http://havens.<KXX.com>/`) berfungsi dan dirutekan dengan benar oleh **Sirion**.

### 20\. Beranda dan Tautan di $ \text{Sirion}$

**Tujuan:** Menyediakan halaman beranda di **Sirion** (*Reverse Proxy*) dan mengonfigurasi Nginx untuk melayani halaman tersebut sebagai *default location* (`/`).

**Hasil Pengerjaan:**

  * **Aksi 1: Pembuatan Halaman:** Membuat direktori `/var/www/sirion\_beranda` dan file `index.html` dengan judul **“War of Wrath: Lindon bertahan”** dan tautan relatif ke `/app/` dan `/static/`.
  * **Aksi 2: Konfigurasi Nginx (Sirion):** Menambahkan blok `location /` di *virtual host* `www.<KXX.com>` di **Sirion** untuk melayani file `index.html` ini sebagai halaman utama, sementara blok *proxy\_pass* lainnya tetap berfungsi.
  * **Perubahan Konfigurasi Nginx (Sirion):**
    ```nginx
    # Blok server www.<KXX.com>
    ...
    location / {
        root /var/www/sirion_beranda;
        index index.html;
    }

    location /app/ { ... } ; Blok proxy_pass tetap utuh
    location /static/ { ... } ; Blok proxy_pass tetap utuh
    ```
  * **Verifikasi:** Mengakses `http://www.<KXX.com>/` menampilkan beranda, dan menelusuri tautan **Kunjungi Pelabuhan Statis** dan **Dengarkan Kisah Dinamis** berhasil merutekan ke **Lindon** dan **Vingilot** melalui Sirion.
