create table temp_tide_longhu as
select f.city, f.lon, f.lat, f.date, f.matchh
from (
select a.uid, a.city, a.lon, a.lat, a.date, b.matchh
from stay_month_longhu a
inner join lc_time_map1 b
on substr(cast(stime as String),12,2)=b.beginh and substr(cast(etime as String),12,2)=b.endh
group by a.uid, a.city, a.lon, a.lat, a.date, b.matchh
) f
group by f.city, f.lon, f.lat, f.date, f.matchh
;

select city, lon, lat, date matchh from temp_tide_longhu limit 1000;
