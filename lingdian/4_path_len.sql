
select prov_id, spot, count(distinct uid) as cuid, count(1) as n, sum(r) as sr, max(r) as mr
from temp_ld20180717_table2
group by prov_id, spot;
