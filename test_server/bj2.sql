create table lc2 as 
select 
final_grid_id,ptype,gender_level,age_level,is_local,u_num,w_num,
cast(row_number() over(partition by 1) / 150000 as int) as index
from lc1;

################

select index, count(1) as count from lc2 group by index;
