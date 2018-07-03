drop table if exists pool;
create table pool as
select a.uid, a.area, b.prov_id, a.grid_id
from openlab.area_code b
inner join (select sm.uid, ua.area, sm.grid_id
from openlab.stay_month sm
inner join openlab.user_attribute ua
on sm.uid = ua.uid
where sm.date = 20170901 and sm.city = 'V0310000'
and sm.is_core = 'N'
group by sm.uid, ua.area, sm.grid_id) a 
on a.area = b.area_id
where prov_id in ('030','034','051','036','011')
;
drop table if exists pool2; 
create table pool2 as
select p.uid, p.prov_id, p.grid_id, 
sp.weighted_centroid_lat as lat, sp.weighted_centroid_lon as lon
from pool p inner join openlab.stay_poi sp
on p.uid = sp.uid and p.grid_id = sp.final_grid_id;
drop table if exists pool3;
create table pool3 as
select p.uid, p.prov_id, p.grid_id, p.lat, p.lon,
sm.stime, sm.etime, sm.ptype
from pool2 p inner join openlab.stay_month sm
on p.uid = sm.uid and p.grid_id = sm.grid_id
where sm.date = 20170901;
