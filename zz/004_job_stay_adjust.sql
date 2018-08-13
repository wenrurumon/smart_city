select cast(sum(x.gw) as bigint) as n, x.ptype, x.age, x.is_core
from 
(select a.uid, sum(a.ptype) as ptype, a.is_core, 
case when u.age = '01' then 'F' 
when u.age = '02' then 'F' 
when u.age = '03' then 'F'
when u.age = '04' then 'F' 
when u.age = '05' then 'F'
when u.age = '06' then 'T'
when u.age = '07' then 'T'
when u.age = '08' then 'T'
when u.age = '09' then 'T'
when u.age = '10' then 'T'
when u.age = '11' then 'T'
when u.age = '12' then 'F'
when u.age = '13' then 'F'
when u.age = '14' then 'F'
when u.age = '15' then 'F'
end as age,
u.gw
from stay_poi a 
inner join user_attribute u
on a.uid = u.uid
where a.ptype in (1,2) and a.city = 'V0370100' and u.city = 'V0370100' and a.date = 20180401 and u.date=20180401
group by a.uid, a.is_core,
case when u.age = '01' then 'F' 
when u.age = '02' then 'F' 
when u.age = '03' then 'F'
when u.age = '04' then 'F' 
when u.age = '05' then 'F'
when u.age = '06' then 'T'
when u.age = '07' then 'T'
when u.age = '08' then 'T'
when u.age = '09' then 'T'
when u.age = '10' then 'T'
when u.age = '11' then 'T'
when u.age = '12' then 'F'
when u.age = '13' then 'F'
when u.age = '14' then 'F'
when u.age = '15' then 'F'
end, u.gw) x
group by x.age, x.is_core, x.ptype
;
