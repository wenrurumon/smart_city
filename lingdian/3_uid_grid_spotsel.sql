
create table temp_ld20180717_table2 as
uid, gender, age, prov_id, min(stime) as stime, gw, spot as spot1,
cast(sum(unix_timestamp(etime)-unix_timestamp(stime)) as bigint) as dtime,
from temp_lc_pool_20180712
where spot != 'NULL'
group by uid, gender, age, prov_id, spot
order by uid, stime
;
