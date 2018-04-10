create table temp0410_sh1 as
select
sp2.date, sp2.ptype, sp2.city, 
floor((sp2.weighted_centroid_lat - m.slat)/m.mlat) as lat,
floor((sp2.weighted_centroid_lon - m.slon)/m.mlon) as lon,
sp2.local, sp2.gender, sp2.age,
cast(sum(sp2.weight) as bigint) as n
from (
select city_code, min(ext_min_x) as slon, min(ext_min_y) as slat,
avg(ext_max_x-ext_min_x) as mlon, avg(ext_max_y-ext_min_y) as mlat
from ss_grid_wgs84
where city_code = 'V0310000'
group by city_code
) m inner join (
select sp.uid, sp.date, sp.ptype, sp.city, sp.weighted_centroid_lat, sp.weighted_centroid_lon, 
case when u.gender='01' then 'M' else 'F' end as gender,
case when u.age = '01' then '0-6' 
when u.age = '02' then '7-12' 
when u.age = '03' then '13-15' 
when u.age = '04' then '16-18' 
when u.age = '05' then '19-24' 
when u.age = '06' then '25-29' 
when u.age = '07' then '30-34' 
when u.age = '08' then '35-39' 
when u.age = '09' then '40-44' 
when u.age = '10' then '45-49' 
when u.age = '11' then '50-54' 
when u.age = '12' then '55-59'
when u.age = '13' then '60-64'
when u.age = '14' then '65-69' 
when u.age = '15' then '70+' 
end as age,
case when u.area = sp.city then "L" else "N" end as local,
case when u.area = sp.city then u.weight else 1 end as weight
from stay_poi sp inner join user_attribute u
on sp.uid = u.uid and sp.city = u.city and sp.date = u.date
where sp.city = 'V0310000' and u.city = 'V0310000'
) sp2
on m.city_code = sp2.city
group by sp2.date, sp2.ptype, sp2.city, sp2.local, sp2.gender, sp2.age,
floor((sp2.weighted_centroid_lat - m.slat)/m.mlat),
floor((sp2.weighted_centroid_lon - m.slon)/m.mlon)
;

select date, ptype, city, lat, lon, local, gender, age, n from temp0410_sh1;
