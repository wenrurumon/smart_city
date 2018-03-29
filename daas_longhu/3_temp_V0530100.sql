create table temp_V0530100 as 
select f.city, f.date, f.lat, f.lon, f.matchh, sum(f.w) as w,
cast(row_number() over(partition by 1) / 50000 as int) as slides
from (
select t.city, t.date, t.lat, t.lon, ti.matchh, t.w, t.uid
from (
select sm.uid, sm.city, sm.lat, sm.lon, sm.date,
substr(cast(sm.stime as String),12,2) as stime,
substr(cast(sm.etime as String),12,2) as etime,
(cast(case when sm.city = u.area then weight else 1 end as Bigint)) as w
from user_attribute u
inner join stay_month_longhu sm
on u.uid = sm.uid and u.city = sm.city
where sm.city = 'V0530100' and u.city = 'V0530100'
group by sm.uid, sm.city, sm.lat, sm.lon, sm.date,
substr(cast(sm.stime as String),12,2),
substr(cast(sm.etime as String),12,2),
(cast(case when sm.city = u.area then weight else 1 end as Bigint))
) t
inner join lc_time_map1 ti
on t.stime = ti.beginh and t.etime = ti.endh
group by t.city, t.date, t.lat, t.lon, ti.matchh, t.w, t.uid
) f
group by city, date, lat, lon, matchh
;

select date, matchh, slides, count(1) from temp_V0530100 group by date, matchh, slides;

