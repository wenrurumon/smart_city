select * from (
select final_grid_id, ptype, count(1) as count, count(distinct uid) as countuid
from stay_poi
where date = 20170901 and city = 'V0110000'
) 
limit 10000;
