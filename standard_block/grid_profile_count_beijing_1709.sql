##########################;
drop table if exists block_beijing_1709;
create table block_beijing_1709 as 
select uid, poi_id, ptype, final_grid_id,
ceil((weighted_centroid_lat - 39.4465405342688 )/ 0.00180115995474959 )
as lat, 
ceil((weighted_centroid_lon - 115.423647357282 )/ 0.00235091975269603 ) 
as lon
from openlab.stay_poi
where date = 20170901 and city = 'V0110000'
;
###########################;
drop table if exists grid_profile_count_beijing_1709;
create table grid_profile_count_beijing_1709 as
select s.lon, s.lat, s.ptype, u.gender, u.age,
case when u.area = u.city then "L" else "N" end as local,
count(1) as n1,	
cast(sum(case when u.area = u.city then u.weight else 1 end) as bigint) as n2
from (
select sp.final_grid_id, sp.uid, sp.ptype, b.lon, b.lat
from openlab.stay_poi sp
inner join block_beijing_1709 b
on sp.final_grid_id = b.final_grid_id and sp.uid = b.uid
where sp.city = 'V0110000' and sp.date = 20170901
) s
inner join openlab.user_attribute u
on s.uid = u.uid
where u.city = 'V0110000' and u.date = 20170901
group by s.lon, s.lat, s.ptype, u.gender, u.age,
case when u.area = u.city then "L" else "N" end
;
