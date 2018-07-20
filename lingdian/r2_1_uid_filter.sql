
#人群确认
#uid, gender, age, gw, prov_id with uid selection

create table temp_ldf0720_uidsel4 as
select x.uid, ac.prov_id, x.gender, x.age, x.gw, x.area
from (
select sm.uid, a.area, a.gw,
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
from stay_month sm inner join user_attribute a
on sm.uid = a.uid
where sm.date in (20180429,20180430) and sm.city = 'V0310000' and a.date = 20180401 and a.city = 'V0310000' and sm.is_core = 'N'
) x
inner join area_code ac
on ac.area_id = x.area
;

select t.prov_id, a.prov_name, count(distinct t.uid) as n from temp_ldf0720_uidsel3 t
inner join area_code a
on t.prov_id = a.prov_id
group by a.prov_name, t.prov_id;
