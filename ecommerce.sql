-- Monthly Transaction Trend
select
    extract(year_month from created_at) as tahun_bulan,
    count(1) as jumlah_transaksi,
    sum(total) as total_nilai_transaksi
from orders
where created_at >= '2020-01-01'
group by 1
order by 1;

-- Top 5 Products Purchased in December 2019
select
    category,
    sum(quantity) as total_quantity,
    sum(quantity * price) as total_price
from orders
inner join order_details using(order_id)
inner join products using(product_id)
where created_at >= '2020-01-01'
and delivery_at is not null
group by 1
order by 2 desc
limit 5;

-- Buyers with More Than 5 Transactions Every Transaction Above 2,000,000
select
    nama_user as nama_pembeli,
    count(1) as jumlah_transaksi,
    sum(total) as total_nilai_transaksi,
    min(total) as min_nilai_transaksi
from orders
inner join users
    on buyer_id = user_id
group by user_id, nama_user
having count(1) > 5
and min(total) > 2000000
order by 3 desc;

-- Dropshipper Detection
select
    nama_user as nama_pembeli,
    count(1) as jumlah_transaksi,
    count(distinct orders.kodepos) as distinct_kodepos,
    sum(total) as total_nilai_transaksi,
    avg(total) as avg_nilai_transaksi
from orders
inner join users
    on buyer_id = user_id
group by user_id, nama_user
having count(1) >= 10
and count(1) = count(distinct orders.kodepos)
order by 2 desc;

-- Offline Reseller Detection Same Shipping Postal Code as Main Address Average Quantity per Transaction > 10
select
    nama_user as nama_pembeli,
    count(1) as jumlah_transaksi,
    sum(total) as total_nilai_transaksi,
    avg(total) as avg_nilai_transaksi,
    avg(total_quantity) as avg_quantity_per_transaksi
from orders
inner join users
    on buyer_id = user_id
inner join (
    select
        order_id,
        sum(quantity) as total_quantity
    from order_details
    group by 1
) summary_order
    using(order_id)
where orders.kodepos = users.kodepos
group by 1
having count(1) >= 8
and avg(total_quantity) > 10
order by 3 desc;

-- Seller Who Also Purchased at Least 7 Times
select nama_user as nama_pengguna, jumlah_transaksi_beli, jumlah_transaksi_jual
from users
inner join (
select buyer_id, count(1) as jumlah_transaksi_beli
from orders
group by 1
) as buyer on buyer_id=user_id
inner join (
select seller_id, count(1) as jumlah_transaksi_jual
from orders
group by 1
) as seller on seller_id=user_id
where jumlah_transaksi_beli>=7
order by 1;

-- Average Payment Delay per Month
select
    extract(year_month from created_at) as tahun_bulan,
    count(order_id) as jumlah_transaksi,
    avg(timestampdiff(day, created_at, paid_at)) as avg_lama_dibayar,
    min(timestampdiff(day, created_at, paid_at)) as min_lama_dibayar,
    max(timestampdiff(day, created_at, paid_at)) as max_lama_dibayar
from orders
where paid_at is not null
group by 1
order by 1