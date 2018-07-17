create table temp_ld20180717_table2 as
select x.uid, x.gender, x.age, x.prov_id, x.stime, x.spot1, x.dtime
from 
(
select uid, gender, age, prov_id, min(stime) as stime, gw, spot as spot1,
cast(sum(unix_timestamp(etime)-unix_timestamp(stime)) as bigint) as dtime
from temp_ld20180717_table1
where spot != 'NULL'
group by uid, gender, age, prov_id, spot, gw
) x
;
