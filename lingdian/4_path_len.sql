
select a.prov_id, count(1) as n, sum(r) as sr, max(r) as mr
from 
(select prov_id, uid, count(1) as r from  temp_ld20180717_table2 group by prov_id, uid) a
group by a.prov_id;
