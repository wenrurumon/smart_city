select *
from 
(
  select t.final_grid_id,t.ptype,
         case when gender='01' then 'M' else 'F' end as gender_level,
         case when age = '01' then '0-6' 
              when age = '02' then '7-12' 
              when age = '03' then '13-15' 
              when age = '04' then '16-18' 
              when age = '05' then '19-24' 
              when age = '06' then '25-29' 
              when age = '07' then '30-34' 
              when age = '08' then '35-39' 
              when age = '09' then '40-44' 
              when age = '10' then '45-49' 
              when age = '11' then '50-54' 
              when age = '12' then '55-59'
              when age = '13' then '60-64'
              when age = '14' then '65-69' 
              when age = '15' then '70以上' 
         end as age_level,
         case when a.area = 'V0110000' then 'Y' else 'N' end as is_local,
         count(1) as u_num,
         cast(round(sum(a.weight)) as bigint) as w_num
  from
  (select s.final_grid_id,s.uid,s.ptype
   from openlab.stay_poi s
   where s.date = 20170901 and s.city = 'V0110000'
   group by s.final_grid_id,s.uid,s.ptype) t 
  inner join openlab.user_attribute a on (t.uid=a.uid)
  where a.date = 20170901 and a.city = 'V0110000'
    and gender in('01','02')
    and age in('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15')
  group by t.final_grid_id,t.ptype,
         case when gender='01' then 'M' else 'F' end,
         case when age = '01' then '0-6' 
              when age = '02' then '7-12' 
              when age = '03' then '13-15' 
              when age = '04' then '16-18' 
              when age = '05' then '19-24' 
              when age = '06' then '25-29' 
              when age = '07' then '30-34' 
              when age = '08' then '35-39' 
              when age = '09' then '40-44' 
              when age = '10' then '45-49' 
              when age = '11' then '50-54' 
              when age = '12' then '55-59'
              when age = '13' then '60-64'
              when age = '14' then '65-69' 
              when age = '15' then '70以上' 
         end,
         case when a.area = 'V0110000' then 'Y' else 'N' end
)
limit 10000;
