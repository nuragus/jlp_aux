## Instalasi PostgreSQL

### Type 1: Instalasi menggunakan paket bawaan distro
Diasumsikan distro adalah Ubuntu Linux
```shell
sudo apt update
sudo apt install postgresql-server postgresql-common
```

**Pros:**
+ Cara termudah melakukan instalasi
+ Juga cara tercepat

**Cons:**
- Direktori terpisah-pisah
- Kemungkinan versi tidak up-to-date
- Add-on modules di install dengan install paket lain
- Kurang mudah untuk compile extra modules

### Type 2: Instalasi menggunakan paket dari enterprisedb
```shell
sudo apt update
sudo apt install wget
wget https://get.enterprisedb.com/postgresql/postgresql-9.6.2-1-linux-x64.run
chmod +x postgresql-9.6.2-1-linux-x64.run
sudo ./postgresql-9.6.2-1-linux-x64.run
```

**Pros:**
+ Instalasi dipandu dengan wizard
+ Direktori terkumpul di satu lokasi
+ Modules sudah cukup lengkap

**Cons:**
- Masih belum cara termudah untuk mengkompile extra modules nantinya

### Type 3: Compile dari source
```shell
sudo apt update
sudo apt install wget curl git
mkdir source_postgres
cd source_postgres
git clone https://github.com/nuragus/jlp_aux.git
chmod +x ./jlp_aux/postgres_compile.sh
./jlp_aux/postgres_compile.sh
```

**Pros:**
+ Instalasi mudah dengan script
+ Direktori terkumpul di satu lokasi
+ Cara termudah untuk mengkompile extra module di kemudian hari

**Cons:**
- Lambat dan membutuhkan computing resource cukup besar

### Direktori-direktori penting (asumsi instalasi menggunakan compile dari source)
**Main Directory:**

`cd $PGDATA` atau

`cd /usr/local/pgsql/data`

**Data Directory:**

`cd $PGDATA/base`

**WAL directory:**

`cd $PGDATA/pg_xlog`

## PostgreSQL Performance

### Benchmark kemampuan komputer melakukan transaksi postgres
**Persiapan Benchmark**
```shell
create database mybench
pgbench -i -s 100 mybench
```

**Jalankan benchmark**
`pgbench -c 100 -j 4 -t 100 mybench`

`-c 100` mensimulasikan 100 koneksi
`-j 4` mensimulasikan 4 concurrent job
`-t 100` mensimulasikan 100 transaksi per koneksi
sehingga total di simulasikan 10000 transaksi

### Trial simulasi dengan database human-resource

Database ini menggunakan berbagai tipe data untuk dapat digunakan sebagai contoh dalam pengukuran performance terhadap data-type

**Pembuatan database**

Buat database dengan berisi table hr sebagai berikut.
```shell
create database hr_benchmark
create type day as enum
('Monday','Tuesday','Wednesday','Thursday','Friday');
create type working_condition as enum ('Permanent','Contract');
drop table if exists employees;
create table employees (
  id int not null,
  room_no smallint not null,
  ktp_no numeric not null,
  name_first varchar,
  name_last varchar,
  join_date timestamp without time zone,
  basic_pay numeric(18,2),
  employee_id serial,
  start_day day,
  working_condition working_condition
);
```

Kemudian buat pl/pgsql function yang melakukan insert random data pegawai
```shell
create or replace function z_insert_employee()
returns setof void as $$
declare
  l_id int;
  l_room_no smallint;
  l_ktp_no numeric;
  l_name_first varchar;
  l_name_last varchar;
  l_join_date timestamp without time zone;
  l_basic_pay money;
  l_random_day smallint;
  l_start_day day;
  l_random_work_cond smallint;
  l_working_condition working_condition;
begin
  select trunc(random() * 1000000 + 1000000) into l_id;
  select trunc(random() * 100 + 1) into l_room_no;
  select trunc(random() * 10000000000000000 + 10000000000000000) into
l_ktp_no;
  select substring(md5(random()::text) from 1 for 8) into l_name_first;
  select substring(md5(random()::text) from 1 for 8) into l_name_last;
  select timestamp '1999-01-01 08:00:00' + random() * interval '17
years' into l_join_date;
  select trunc(random() * 1500000 + 10000000) into l_basic_pay;

  select trunc(random() * 5 + 1) into l_random_day;
  case l_random_day
  when 1 then l_start_day='Monday';
  when 2 then l_start_day='Tuesday';
  when 3 then l_start_day='Wednesday';
  when 4 then l_start_day='Thursday';
  when 5 then l_start_day='Friday';
  end case;

  select trunc(random() *2 + 1) into l_random_work_cond;
  case l_random_work_cond
  when 1 then l_working_condition='Permanent';
  when 2 then l_working_condition='Contract';
  end case;

  insert into employees(id, room_no, ktp_no, name_first, name_last,
join_date, basic_pay, start_day, working_condition)
    values(l_id, l_room_no, l_ktp_no, l_name_first, l_name_last,
l_join_date, l_basic_pay, l_start_day, l_working_condition);
return;
end; $$ language plpgsql;
```

Kemudian buat pl/pgsql yang membuat satu juta random pegawai
```shell
create or replace function z_mass_insert_employee()
returns setof void as $$
declare
begin
  for i in 1..1000000 loop
    perform * from z_insert_employee();
  end loop;
return;
end; $$ language plpgsql;
```

Kemudian generate 1 juta pegawai random dengan memanggil:
`select * from z_mass_insert_employee();`

Aktifkan timing untuk mengukur durasi sebuah query
`\timing`

Test sebuah query misalnya query untuk menampilkan karyawan yang masuk
antara tahun 2010 sampai tahun 2014

`select name_first from employees where join_date between '2010-01-01'
and '2014-12-31' order by join_date limit 10;`

Query tersebut membutuhkan durasi kurang lebih 150ms (milidetik)

Untuk mempercepat query, perlu dilakukan analisa terlebih dahulu dimana
beban terbesar dari query tersebut.

`explain analyze select name_first from employees where join_date
between '2010-01-01' and '2014-12-31' order by join_date limit 10;`

Akan menghasilkan output:
```shell
                                                                           QUERY
PLAN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=38654.47..38654.72 rows=100 width=17) (actual
time=233.836..233.887 rows=100 loops=1)
   ->  Sort  (cost=38654.47..39394.18 rows=295884 width=17) (actual
time=233.833..233.852 rows=100 loops=1)
         Sort Key: join_date
         Sort Method: top-N heapsort  Memory: 32kB
         ->  Seq Scan on employees  (cost=0.00..27346.00 rows=295884
width=17) (actual time=0.015..168.022 rows=294007 loops=1)
               Filter: ((join_date >= '2010-01-01 00:00:00'::timestamp
without time zone) AND (join_date <= '2014-12-31 00:00:00'::timestamp
without time zone))
               Rows Removed by Filter: 705993
 Planning time: 0.072 ms
 Execution time: 234.881 ms
(9 rows)
```

Untuk mempermudah pembacaan hasil analisa query, hasil explain analyze
bisa di copy-paste ke website [depesz](https://explain.depesz.com/)

Dengan pembacaan yang lebih mudah di website **depezs**, dapat dilihat
bahwa beban yang berat ada di sort pada kolom `join_date`. Dari sini
kita dapat mencoba melakukan indexing terhadap kolom tersebut.
`create index idx_employees_join_date on employees(join_date);`

Kemudian lakukan explain analyze.

`explain analyze select name_first from employees where join_date
between '2010-01-01' and '2014-12-31' order by join_date limit 10;`

Hasilnya, query di execute jauh lebih cepat
```shell
                                                                          QUERY
PLAN
---------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=0.42..20.21 rows=100 width=17) (actual time=2.939..3.153
rows=100 loops=1)
   ->  Index Scan using idx_employees_join_date on employees
(cost=0.42..58554.09 rows=295884 width=17) (actual time=2.938..3.121
rows=100 loops=1)
         Index Cond: ((join_date >= '2010-01-01 00:00:00'::timestamp
without time zone) AND (join_date <= '2014-12-31 00:00:00'::timestamp
without time zone))
 Planning time: 1.706 ms
 Execution time: 3.204 ms
(5 rows)
```

**Hint:**

Dimana ada `seq scan` kepanjangan dari sequential scan yaitu kegiatan
database untuk membaca semua row satu persatu, disitulah index
dibutuhkan.

**WARNING:**

Dalam contoh ini query dapat dipercepat dengan menggunakan index. Namun
index yang terlalu banyak akan membuat query dengan tipe `INSERT` atau
`UPDATE` akan menjadi lambat karena harus meng-update index juga.
Sehingga hindari index yang tidak perlu.

Untuk membuktikan, coba ukur durasi yang dibutuhkan untuk men-generate 1
juta employee random sebelum dan sesudah di index.

