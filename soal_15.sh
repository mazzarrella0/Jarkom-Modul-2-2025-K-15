#install tools di Elrond
apt-get update
apt-get install -y apache2-utils

#jalankan perintah ApacheBench pd Elrond (1)
ab -n 500 -c 10 http://www.K15.com/app/
(mendapatkan output 'request per second')

#jalankan perintah ApacheBench pd Elrond (2)
ab -n 500 -c 10 http://www.K15.com/static/
(mendapatkan output 'request per second' yg lbh tinggi)

#/langkah 2 dan 3 akan menjadi perbandingan