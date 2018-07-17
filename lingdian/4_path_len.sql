
select a.prov_id, a.spot1, count(1) as n, sum(r) as sr, max(r) as mr
from 
(select prov_id, uid, spot1, count(1) as r from  temp_ld20180717_table2 group by prov_id, spot1, uid) a
group by a.prov_id, a.spot1;
