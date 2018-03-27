create table stay_month_longhu as
select sm2.uid, sm2.city, sp2.lat, sp2.lon, sm2.nstime as stime, sm2.netime as etime
from (
select sm.uid, sm.city, sm.grid_id, sm.date, 
case when (minstime = stime) then cast(date_format(stime,"yyyy-MM-dd 00:00:00") as timestamp) 
else stime end as nstime,
case when (maxetime = etime) then cast(date_format(etime,"yyyy-MM-dd 23:59:59") as timestamp) 
else etime end as netime
from stay_month sm
inner join (
select uid, city, date, min(stime) as minstime, max(etime) as maxetime
from stay_month
where unix_timestamp(etime) - unix_timestamp(stime) > 0
group by uid, city, date
) sud
on sm.uid = sud.uid and sm.date = sud.date and sm.city = sud.city
where unix_timestamp(sm.etime) - unix_timestamp(sm.stime) > 0
) sm2
inner join (
select sp.city, sp.final_grid_id as grid_id, sp.uid, 
floor((sp.weighted_centroid_lat-m.slat)/m.mlat) as lat,
floor((sp.weighted_centroid_lon-m.slon)/m.mlon) as lon
from stay_poi sp
inner join map_longhu m
on sp.city = m.city_code
) sp2
on sm2.uid = sp2.uid and sm2.grid_id = sp2.grid_id and sm2.city = sp2.city
group by sm2.uid, sm2.city, sp2.lat, sp2.lon, sm2.nstime, sm2.netime
;

select city, date, count(1) as n from stay_month_longhu group by city, date;
