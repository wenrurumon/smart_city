select final_grid_id, count(distinct uid) as count from (select final_grid_id, uid from stay_poi limit 100000) group by final_grid_id;
