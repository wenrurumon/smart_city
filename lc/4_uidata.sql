drop table if exists lc.uidata;
create table lc.uidata as 
select sp2.uid, sp2.date, sp2.city, sp2.is_core, sp2.weight, 
case when sp2.gender='01' then 'M' else 'F' end as gender,
case when sp2.age = '01' then '0-6' 
when sp2.age = '02' then '7-12' 
when sp2.age = '03' then '13-15' 
when sp2.age = '04' then '16-18' 
when sp2.age = '05' then '19-24' 
when sp2.age = '06' then '25-29' 
when sp2.age = '07' then '30-34' 
when sp2.age = '08' then '35-39' 
when sp2.age = '09' then '40-44' 
when sp2.age = '10' then '45-49' 
when sp2.age = '11' then '50-54' 
when sp2.age = '12' then '55-59'
when sp2.age = '13' then '60-64'
when sp2.age = '14' then '65-69' 
when sp2.age = '15' then '70+' 
end as age,
floor((sp2.lat1-m.slat)/m.mlat) as lat1, 
floor((sp2.lon1-m.slon)/m.mlon) as lon1,
case when sp2.lat2 is NULL and sp2.age in ('06','07','08','09','10','11','12') then 
floor((sp2.lat1-m.slat)/m.mlat) else floor((sp2.lat2-m.slat)/m.mlat) end as lat2,
case when sp2.lon2 is NULL and sp2.age in ('06','07','08','09','10','11','12') then 
floor((sp2.lon1-m.slon)/m.mlon) else floor((sp2.lon2-m.slon)/m.mlon) end as lon2,
floor((sp2.lat0-m.slat)/m.mlat) as lat0, 
floor((sp2.lon0-m.slon)/m.mlon) as lon0
from (
select city_code, min(ext_min_x) as slon, min(ext_min_y) as slat, 
avg(ext_max_x-ext_min_x) as mlon, avg(ext_max_y-ext_min_y) as mlat
from ss_grid_wgs84
where city_code = 'V0110000'
group by city_code
) m inner join (
select t.uid, t.date, sp.city, t.age, t.gender, t.weight, t.is_core,
max(case t.ptype when 1 then sp.weighted_centroid_lat end) as lat1,
max(case t.ptype when 1 then sp.weighted_centroid_lon end) as lon1,
max(case t.ptype when 2 then sp.weighted_centroid_lat end) as lat2,
max(case t.ptype when 2 then sp.weighted_centroid_lon end) as lon2,
max(case t.ptype when 0 then sp.weighted_centroid_lat end) as lat0,
max(case t.ptype when 0 then sp.weighted_centroid_lon end) as lon0
from stay_poi sp inner join (
select s.uid, s.ptype, s.date, max(s.weekday_day_time) as wdt,
u.weight, s.is_core, u.gender, u.age
from stay_poi s inner join user_attribute u
on s.uid = u.uid and s.date = u.date and s.city = u.city
where s.city = 'V0110000' and s.date = 20170901
and u.age in('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15')
and u.gender in ('01','02')
group by s.uid, s.ptype, s.date, s.is_core, u.gender, u.age, u.weight
) t
on sp.uid = t.uid and sp.ptype = t.ptype and sp.date = t.date and sp.weekday_day_time = t.wdt
where sp.city = 'V0110000' and sp.date = 20170901
group by t.uid, t.date, sp.city, t.age, t.gender, t.weight, t.is_core) sp2
on sp2.city = m.city_code
;

