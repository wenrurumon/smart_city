create table temp0425_1 as
select 
uid,
floor((sp.weighted_centroid_lat - m.slat)/m.mlat) as lat,
floor((sp.weighted_centroid_lon - m.slon)/m.mlon) as lon
from stay_poi sp inner join (
select city_code, min(ext_min_x) as slon, min(ext_min_y) as slat,
avg(ext_max_x-ext_min_x) as mlon, avg(ext_max_y-ext_min_y) as mlat
from ss_grid_wgs84
where city_code = 'V0310000'
group by city_code
) m
where sp.ptype = 0 and sp.city = 'V0310000';

create table temp0425_2 as
select uid
where lat in (296,297,298,299,300,301,302,304,305,307,308,310)
and lon in (200,201,202,203,204,205,207,208,209,210,211)
and lat*1000+lon in (296207,296208,296209,296210,296211,296212,298200,298201,299200,300212,302212,304202,305202,307213,307214,308213,310204,310205,297212,298212,299212,301212)
;

create table temp0425_3 as
select sp.uid, u.gw
from temp0425_2 sp 
inner join user_attribute u
on sp.uid = u.uid
;

create table temp0425_4 as
select sp.uid, sp.ptype,
floor((sp.weighted_centroid_lat - m.slat)/m.mlat) as lat,
floor((sp.weighted_centroid_lon - m.slon)/m.mlon) as lon,
u.gw
from stay_poi sp
inner join temp0425_3 u
on sp.uid = u.uid
inner join (
select city_code, min(ext_min_x) as slon, min(ext_min_y) as slat,
avg(ext_max_x-ext_min_x) as mlon, avg(ext_max_y-ext_min_y) as mlat
from ss_grid_wgs84
where city_code = 'V0310000'
group by city_code
) m
where sp.city = 'V0310000'
;

create table temp0425_5 as
select ptype, lat, lon, count(1) as u, cast(sum(gw) as bigint) as n
from temp0425_4
group by ptype, lat, lon;
select ptype, lat, lon, u, n from temp0425_5 limit 350000;

create table temp0425_6 as
select ptype, lat, lon, u, n, 
cast(row_number() over(partition by 1) / 350000 as int) as slides
from temp0425_5;





