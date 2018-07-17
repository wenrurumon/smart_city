
create table temp_lc_pool_20180712_sel as
select x.uid, x.gender, x.age, x.prov_id,
min(x.stime) as stime, max(x.etime) as etime, sum(dtime) as dtime,
x.spot0, x.spot from
(
select 
uid, gender, age, prov_id, stime, etime, 
cast((unix_timestamp(etime)-unix_timestamp(stime)) as bigint) as dtime,
gw, spot, lag(spot,1,spot) over(partition by uid order by stime) as spot0
from temp_lc_pool_20180712
where spot != 'NULL'
order by uid, stime
) x
group by x.uid, x.gender, x.age, x.prov_id, x.spot0, x.spot
order by x.uid
;

create table temp_lc_pool_20180717_sel as
select x.uid, x.gender, x.age, x.prov_id,
min(x.stime) as stime, max(x.etime) as etime, sum(dtime) as dtime,
x.spot0, x.spot1, x.spot2 from
(
select 
uid, gender, age, prov_id, stime, etime, 
cast((unix_timestamp(etime)-unix_timestamp(stime)) as bigint) as dtime,
gw, spot as spot1, 
lag(spot,1,spot) over(partition by uid order by stime) as spot0
lead(spot,1,spot) over(partition by uid order by stime) as spot2
from temp_lc_pool_20180712
where spot != 'NULL'
order by uid, stime
) x
group by x.uid, x.gender, x.age, x.prov_id, x.spot0, x.spot1, x.spot2
order by x.uid
;

#景区信息
select x.gender, x.age, x.prov_id, x.spot, count(1) as n, sum(x.dtime) as dtime
from
(
select uid, gender, age, prov_id, sum(dtime) as dtime, spot
from temp_lc_pool_20180712_sel
group by uid, gender, age, prov_id, spot
) x
group by x.gender, x.age, x.prov_id, x.spot
;

#景区路径
select b.prov_id, b.spot0, b.spot1, b.spot2, sum(b.d0) as d0, sum(b.d1) as d1, sum(b.d2) as d2, count(1) as n
from 
(
select a.uid, a.prov_id, a.dtime as d1,
lag(a.dtime,1,0) over (partition by uid order by stime) as d0,
lead(a.dtime,1,0) over (partition by uid order by stime) as d2,
a.spot1,
lag(a.spot1,1,0) over (partition by uid order by stime) as spot0,
lead(a.spot1,1,0) over (partition by uid order by stime) as spot2
from
(
select uid, prov_id, stime,
cast(sum(unix_timestamp(etime)-unix_timestamp(stime)) as bigint) as dtime,
spot as spot1
from temp_lc_pool_20180712
where spot != 'NULL'
group by uid, prov_id, spot, stime
) a
) b
group by b.prov_id, b.spot0, b.spot1, b.spot2;

select b.prov_id, b.spot0, b.spot1, sum(b.d0) as d0, sum(b.d1) as d1, count(1) as n
from 
(
select a.uid, a.prov_id, a.dtime as d1,
lag(a.dtime,1,0) over (partition by uid order by stime) as d0,
a.spot1,
lag(a.spot1,1,0) over (partition by uid order by stime) as spot0
from
(
select uid, prov_id, stime,
cast(sum(unix_timestamp(etime)-unix_timestamp(stime)) as bigint) as dtime,
spot as spot1
from temp_lc_pool_20180712
where spot != 'NULL'
group by uid, prov_id, spot, stime
) a
) b
group by b.prov_id, b.spot0, b.spot1;


