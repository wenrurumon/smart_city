create table lc2 as 
select final_grid_id, ptype, count(1) as count, count(distinct uid) as countuid
from stay_poi
where date = 20170901 and city = 'V0110000'
group by final_grid_id,ptype;

select count(1) from lc2;
