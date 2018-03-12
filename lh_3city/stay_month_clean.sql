create table stay_month_longhu as
select f.uid, f.city, f.grid_id, f.ptype, f.date, f.nstime as stime, f.netime as etime
from (
select sm.uid, sm.city, sm.grid_id, sm.ptype, sm.date, 
case when (minstime = stime) then cast(date_format(stime,"yyyy-MM-dd 00:00:00") as timestamp) 
else stime end as nstime,
case when (maxetime = etime) then cast(date_format(etime,"yyyy-MM-dd 23:59:59") as timestamp) 
else etime end as netime
from stay_month sm
left join (
select uid, city, date, min(stime) as minstime, max(etime) as maxetime
from stay_month
where city in ('V0500000','V0520100','V0530100')
group by uid, city, date
) sud
on sm.uid = sud.uid and sm.date = sud.date and sm.city = sud.city
where sm.city in ('V0500000','V0520100','V0530100')
) f
where unix_timestamp(f.netime) - unix_timestamp(f.nstime) > 1800
;
