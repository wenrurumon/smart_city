create table temp26_test2 as
select t.city, t.lon, t.lat, t.ptype, t.uid, t.local,
avg(t.hours) as hours, count(1) as days, t.w
from (
	select sm.city, sm.lon, sm.lat , sm.ptype, sm.date, sm.uid,
	case when u.area = sm.city then "L" else "N" end as local,
	u.age,
	u.gender,
	sum((unix_timestamp(sm.etime) - unix_timestamp(sm.stime))/3600) as hours,
	cast((case when u.area = u.city then u.weight else 1 end) as bigint) as w
	from (
		select f.uid, f.city, f.ptype, f.date, f.nstime as stime, f.netime as etime, f.lat, f.lon
		from (
		select smr.uid, smr.city, smr.ptype, smr.date, sp.lat, sp.lon,
		case when (minstime = smr.stime) then cast(date_format(smr.stime,"yyyy-MM-dd 00:00:00") as timestamp)
		else smr.stime end as nstime,
		case when (maxetime = smr.etime) then cast(date_format(smr.etime,"yyyy-MM-dd 23:59:59") as timestamp)
		else smr.etime end as netime
		from stay_month smr
		inner join (
		select uid, city, date, min(stime) as minstime, max(etime) as maxetime
		from stay_month
		where city in ('V0110000')
		and unix_timestamp(etime) - unix_timestamp(stime) > 0
		group by uid, city, date
		) sud
		on smr.uid = sud.uid and smr.date = sud.date and smr.city = sud.city
		inner join (
		select uid, final_grid_id, ptype,
		floor((weighted_centroid_lat-39.44275803)/0.002253562647387424) as lat,
		floor((weighted_centroid_lon-115.42341096)/0.0029288712627366896) as lon
		from stay_poi
		where city in ('V0110000') and date = 20170901
		group by uid, final_grid_id, ptype,
		floor((weighted_centroid_lat-39.44275803)/0.002253562647387424),
		floor((weighted_centroid_lon-115.42341096)/0.0029288712627366896)
		) sp
		on smr.uid = sp.uid and smr.grid_id = sp.final_grid_id and smr.ptype = sp.ptype
		where smr.city in ('V0110000')
		and unix_timestamp(smr.etime) - unix_timestamp(smr.stime) > 0
		) f
		where unix_timestamp(f.netime) - unix_timestamp(f.nstime) > 1800
	) sm
	inner join user_attribute u
	on sm.uid = u.uid and sm.city = u.city
	where sm.city in ('V0110000')
	and u.city in ('V0110000') 
	group by sm.city, sm.lon, sm.lat, sm.ptype, sm.date, sm.uid,
	case when u.area = sm.city then "L" else "N" end,
	cast((case when u.area = u.city then u.weight else 1 end) as bigint),
	u.age,
	u.gender
	) t
where t.ptype = 1 and t.local = "L"
group by t.city, t.lon, t.lat, t.ptype, t.uid, t.local, t.w;
#######################;
select
case when hours < 8 then "H00"
when (hours)>=8 and (hours)<16 then "H08"
when (hours)>=16 and (hours)<21 then "H16"
when (hours)>=21 and (hours)<23 then "H21"
when (hours)>=23 and (hours)<23.999722 then "H23"
when (hours)>23.999722 then "H24" 
end as hours,
sum(w) as n
from temp26_test2
where ptype = 1 and days > 2
group by
case when hours < 8 then "H00"
when (hours)>=8 and (hours)<16 then "H08"
when (hours)>=16 and (hours)<21 then "H16"
when (hours)>=21 and (hours)<23 then "H21"
when (hours)>=23 and (hours)<23.999722 then "H23"
when (hours)>23.999722 then "H24" 
end;
