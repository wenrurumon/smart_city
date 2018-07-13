
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
