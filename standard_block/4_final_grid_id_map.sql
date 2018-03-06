create table final_grid_id_map as 
select uid, ptype, final_grid_id,
ceil((avg(weighted_centroid_lat) - 39.4465405342688 )/ 0.00235091975269603) as lat, 
ceil((avg(weighted_centroid_lon) - 115.423647357282 )/ 0.00180115995474959 ) as lon
from openlab.stay_poi
where date = 20170901 and city = 'V0110000'
group by uid, ptype, final_grid_id;
