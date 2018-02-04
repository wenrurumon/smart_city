select final_grid_id, ptype, count(1) from 
(select final_grid_id, ptype from stay_poi limit 1000)
group by final_grid_id;
