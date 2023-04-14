	--Total Penjualan dan Revenue pada Quarter-1 (Jan, Feb, Mar) dan Quarter-2 (Apr,Mei,Jun)

select sum(quantity) as total_penjualan,
sum(priceEach * quantity) as revenue
from orders_1
where status = 'Shipped';

select sum(quantity) as total_penjualan,
sum(priceEach * quantity) as revenue
from orders_2
where status = 'Shipped';

/* output

+-----------------+-----------+
| total_penjualan | revenue   |
+-----------------+-----------+
|            8694 | 799579310 |
+-----------------+-----------+
+-----------------+-----------+
| total_penjualan | revenue   |
+-----------------+-----------+
|            6717 | 607548320 |
+-----------------+-----------+

*/

-----------------------------------------------------------------------------------------------------------------------------------

	--Menghitung keseluruhan penjualan dan revenue

select quarter, sum(quantity) as total_penjualan, sum(priceEach * quantity) as revenue
from 
(select orderNumber, status, quantity, priceEach, 1 as quarter from orders_1
UNION
select orderNumber, status, quantity, priceEach, 2 as quarter from orders_2) as tableref
where status = 'Shipped'
group by 1

/*output

+---------+-----------------+-----------+
| quarter | total_penjualan | revenue   |
+---------+-----------------+-----------+
|       1 |            8694 | 799579310 |
|       2 |            6717 | 607548320 |
+---------+-----------------+-----------+

*/

-----------------------------------------------------------------------------------------------------------------------------------

/*Perhitungan Growth Penjualan dan Revenue
Untuk project ini, perhitungan pertumbuhan penjualan akan dilakukan secara manual menggunakan formula yang disediakan di bawah.
Adapun perhitungan pertumbuhan penjualan dengan SQL dapat dilakukan menggunakan “window function” yang akan dibahas di materi DQLab berikutnya.

 %Growth Penjualan = (6717 – 8694)/8694 = -22%

%Growth Revenue = (607548320 – 799579310)/ 799579310 = -24%*/

-----------------------------------------------------------------------------------------------------------------------------------

	--Apakah jumlah customers xyz.com semakin bertambah?

select quarter, count(customerID)
as total_customers
from
(select customerID, createDate, QUARTER(createDate) as quarter from customer
where createDate between '2004-01-01' and '2004-06-30'
order by createDate) as tableref
group by 1

/*output =

+---------+-----------------+
| quarter | total_customers |
+---------+-----------------+
|       1 |              43 |
|       2 |              35 |
+---------+-----------------+

pada quarter 1 terdapat 43 customers yang registrasi
pada quarter 2 terdapat 35 customers yang registrasi

*/

-----------------------------------------------------------------------------------------------------------------------------------

	--Seberapa banyak customers tersebut yang sudah melakukan transaksi???

select quarter, count(customerID) as total_customers
from
(select customerID, createDate, QUARTER(createDate) as quarter
from customer
where createDate between
'2004-01-01' and '2004-06-30'
order by 2) as tableref
where customerID IN
(select distinct customerID
from orders_1
union
select distinct customerID
FROM orders_2)
group by 1

/* output

+---------+-----------------+
| quarter | total_customers |
+---------+-----------------+
|       1 |              25 |
|       2 |              19 |
+---------+-----------------+

Hanya 25 customer yang sudah melakukan transaksi selama jan-jun dari total 43 customers yang regist di quarter 1 
Hanya 19 customer yang sudah melakukan transaksi selama jan-jun dari total 35 customers yang regist di quarter 2

*/

-----------------------------------------------------------------------------------------------------------------------------------

	--Category produk apa saja yang paling banyak di-order oleh customers di Quarter-2?

select * from
(select categoryID as categoryid, count(distinct orderNumber) as total_order, sum(quantity) as total_penjualan
FROM
(select productCode, orderNumber, quantity, status, left(productCode, 3) as categoryID
from orders_2
where status = 'Shipped') AS tableref
group by 1) as tableref_2
order by total_order desc

/*output

+------------+-------------+-----------------+
| categoryid | total_order | total_penjualan |
+------------+-------------+-----------------+
| S18        |          25 |            2264 |
| S24        |          21 |            1826 |
| S32        |          11 |             616 |
| S12        |          10 |             491 |
| S50        |           8 |             292 |
| S10        |           8 |             492 |
| S70        |           7 |             675 |
| S72        |           2 |              61 |
+------------+-------------+-----------------+

*/

-----------------------------------------------------------------------------------------------------------------------------------

	--Seberapa banyak customers yang tetap aktif bertransaksi setelah transaksi pertamanya?

#Menghitung total unik customers yang transaksi di quarter_1
SELECT COUNT(DISTINCT customerID) as total_customers FROM orders_1;
#output = 25

select quarter, q2_q1/25*100 as Q2
from
(select count(distinct customerID) as q2_q1, 1 as quarter from orders_1
where customerID IN
(SELECT distinct customerID
FROM orders_2)) as tableref

/*output

+---------+---------+
| quarter | Q2      |
+---------+---------+
|       1 | 24.0000 |
+---------+---------+

hanya 24% dari total pembeli di q1 yang bertransaksi lagi di q2

*/

-----------------------------------------------------------------------------------------------------------------------------------

/*

Berdasarkan data yang telah kita peroleh melalui query SQL, Kita dapat menarik kesimpulan bahwa :

1. Performance xyz.com menurun signifikan di quarter ke-2, terlihat dari nilai penjualan dan revenue yang drop hingga 20% dan 24%,

2. Perolehan customer baru juga tidak terlalu baik, dan sedikit menurun dibandingkan quarter sebelumnya.

3. Ketertarikan customer baru untuk berbelanja di xyz.com masih kurang, 
hanya sekitar 56% saja yang sudah bertransaksi. 
Disarankan tim Produk untuk perlu mempelajari behaviour customer dan melakukan product improvement,
sehingga conversion rate (register to transaction) dapat meningkat.

4. Produk kategori S18 dan S24 berkontribusi sekitar 50% dari total order dan 60% dari total penjualan, 
sehingga xyz.com sebaiknya fokus untuk pengembangan category S18 dan S24.

5. Retention rate customer xyz.com juga sangat rendah yaitu hanya 24%, 
artinya banyak customer yang sudah bertransaksi di quarter-1 tidak kembali melakukan order di quarter ke-2 (no repeat order).

6. xyz.com mengalami pertumbuhan negatif di quarter ke-2 dan 
perlu melakukan banyak improvement baik itu di sisi produk dan bisnis marketing, 
jika ingin mencapai target dan positif growth di quarter ke-3. 
Rendahnya retention rate dan conversion rate bisa menjadi diagnosa awal bahwa customer tidak tertarik/kurang puas/kecewa berbelanja di xyz.com.

*/