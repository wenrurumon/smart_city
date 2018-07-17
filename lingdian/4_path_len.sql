
select a.prov_id, a.spot
from 
(select prov_id, uid, spot, count(1) from  temp_ld20180717_table2) a
group by a.prov_id, a.spot;
