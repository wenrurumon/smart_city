create table temp24 as
select city from stay_month limit 24
;

create table time_map as
select substr(cast(a.r as String),2,2) as stime, substr(cast(b.r as String),2,2) as etime 
from 
(select (row_number() over())+99 as r from temp24 limit 24) a, 
(select (row_number() over())+99 as r from temp24 limit 24) b
where a.r <= b.r
;
