create table gpc_beijing1709_2 as
select 
floor((sp.weighted_centroid_lat-39.44275803)/0.002253562647387424) as lat,
floor((sp.weighted_centroid_lon-115.42341096)/0.0029288712627366896) as lon,
sp.ptype, 
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
case when u.area = u.city then "L" else "N" end as local,
count(1) as n1,
cast(sum(case when u.area = u.city then u.weight else 1 end) as bigint) as n2,
cast(row_number() over(partition by 1) / 150000 as int) as slides
from stay_poi sp
inner join user_attribute u
on sp.uid = u.uid
where u.city = 'V0110000' and sp.city = 'V0110000'
and u.date = 20170901 and sp.date = 20170901
and u.gender in ('01','02') and u.age in ('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15')
group by 
floor((sp.weighted_centroid_lat-39.44275803)/0.002253562647387424),
floor((sp.weighted_centroid_lon-115.42341096)/0.0029288712627366896),
sp.ptype, 
case when u.gender='01' then 'M' else 'F' end, 
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
end,
case when u.area = u.city then "L" else "N" end;
