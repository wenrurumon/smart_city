
create table lc_example_1 as
select t.fnid,count(1) as num,cast(round(sum(t.weight)) as bigint) as wnum from
(select g.fnid,s.uid,a.weight
from stay_poi s 
inner join user_attribute a on s.uid = a.uid and a.city = 'V0310000' and a.date = 20171101
inner join ss_grid_wgs84 g on s.city = g.city_code 
and ceil((s.weighted_centroid_lon - 120.85680492)/0.00265333)= g.gcol_4326
and ceil((s.weighted_centroid_lat - 30.67559298)/0.00225447) = g.grow_4326  
where s.date = 20171101 and s.city = 'V0310000' and s.ptype = 1 and s.is_core = 'Y') t
group by t.fnid;
