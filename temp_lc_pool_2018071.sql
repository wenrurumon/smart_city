create table temp_lc_pool_20180710 as
select t.uid, t.gender, t.age, t.area, t.prov_id, t.grid_id, t.ptype, t.stime, t.etime, t.gw, 
floor((t.lat - m.slat)/m.mlat) as lat,
floor((t.lon - m.slon)/m.mlon) as lon
from (
select city_code, min(ext_min_x) as slon, min(ext_min_y) as slat,
avg(ext_max_x-ext_min_x) as mlon, avg(ext_max_y-ext_min_y) as mlat
from ss_grid_wgs84
where city_code = 'V0310000' 
group by city_code
) m inner join (
select x.uid, x.age, x.gender, x.area, x.prov_id, x.grid_id, x.ptype, x.stime, x.etime, x.gw, 
s.weighted_centroid_lon as lon, s.weighted_centroid_lat as lat
from (
select a.uid, a.area, b.prov_id, a.grid_id, a.ptype, a.stime, a.etime, a.gw,
case when a.gender='01' then 'M'
when a.gender = '02' then 'F' 
end as gender,
case when a.age = '01' then '0-6' 
when a.age = '02' then '7-12' 
when a.age = '03' then '13-15' 
when a.age = '04' then '16-18' 
when a.age = '05' then '19-24' 
when a.age = '06' then '25-29' 
when a.age = '07' then '30-34' 
when a.age = '08' then '35-39' 
when a.age = '09' then '40-44' 
when a.age = '10' then '45-49' 
when a.age = '11' then '50-54' 
when a.age = '12' then '55-59'
when a.age = '13' then '60-64'
when a.age = '14' then '65-69' 
when a.age = '15' then '70+' 
end as age
from area_code b
inner join (select sm.uid, ua.area, sm.grid_id, ua.gender, ua.age, sm.ptype, sm.stime, sm.etime, ua.gw
from stay_month sm
inner join user_attribute ua
on sm.uid = ua.uid
where sm.date = 20180501 and sm.city = 'V0310000' and ua.date = 20180501 and ua.city = 'V0310000'
and sm.is_core = 'N'
group by sm.uid, ua.area, sm.grid_id, ua.gender, ua.age, sm.ptype, sm.stime, sm.etime, ua.gw) a 
on a.area = b.area_id
where b.prov_id in ('030','034','051','036','011')
) x
inner join stay_poi s
on x.uid = s.uid and x.grid_id = s.final_grid_id
where s.date = 20180501 and s.city = 'V0110000'
) t
;
