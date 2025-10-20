# Jarkom-Modul-2-2025-K-15


|No|Nama anggota|NRP|
|---|---|---|
|1. | Evan Christian Nainggolan | 5027241026|
|2. | Az Zahrra Tasya Adelia | 5027241087|



## Deskripsi Proyek







## Topologi Jaringan










## Penjelasan tiap soal



>> Ganti `<KXX.com>` dengan *hostname* domain yang sebenarnya `K15.com`

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