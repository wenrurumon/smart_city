drop table if exists block_beijing_1709;
create table block_beijing_1709 as 
select uid, final_grid_id,
ceil((weighted_centroid_lat - 39.5885584030904 )/ 0.00234642548784477 )
as lat, 
ceil((weighted_centroid_lon - 115.858612141601 )/ 0.00180120046545638 )
as lon
from stay_poi
where date = 20170901 and city = 'V0110000'
;
drop table if exists sp2;
create table sp2 as
select sp.final_grid_id, sp.uid, sp.ptype, b.lon, b.lat
from openlab.stay_poi sp
inner join block_beijing_1709 b
on sp.final_grid_id = b.final_grid_id and sp.uid = b.uid
;
drop table if exists x;
create table x as
select s.lon, s.lat, s.ptype, u.gender, u.age,
count(1) as n1,	
cast(sum(u.weight) as bigint) as n2
from sp2 s
left join openlab.user_attribute u
on s.uid = u.uid
group by s.lon, s.lat, s.ptype, u.gender, u.age
;
