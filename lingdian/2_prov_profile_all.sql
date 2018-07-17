
select a.gender, a.age, a.prov_id, cast(sum(a.gw) as bigint) as w, count(1) as n
from (
select uid, gender, age, prov_id, gw from temp_ld20180717_table1
group by uid, gender, age, prov_id, gw
) a
group by a.gender, a.age, a.prov_id;

select lon, lat, ptype, prov_id, count(1) as n, cast(sum(gw) as bigint) as w
from temp_ld20180717_table1 
group by lon, lat, prov_id, ptype;

