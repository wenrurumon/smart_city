
create table temp_ld20180717_table2 as
select x.uid, x.gender, x.age, x.prov_id,
min(x.stime) as stime, max(x.etime) as etime, sum(dtime) as dtime,
x.spot0, x.spot from
(
select 
uid, gender, age, prov_id, min(stime) as stime, gw, spot as spot1,
cast((unix_timestamp(etime)-unix_timestamp(stime)) as bigint) as dtime,
from temp_lc_pool_20180712
where spot != 'NULL'
order by uid, stime
) x
group by x.uid, x.gender, x.age, x.prov_id, x.spot0, x.spot
order by x.uid
;
