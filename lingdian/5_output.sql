
select prov_id, count(1) as n from temp_ld20180717_table2 group by prov_id;

select prov_id, spot1, count(1) as n from temp_ld20180717_table2 group by prov_id, spot1;

select prov_id, spot1, gender, age, count(1) as n from temp_ld20180717_table2 group by prov_id, gender, age, spot1;

select x.prov_id, x.spot1, x.spot2, 
sum(x.d1) as d1, sum(x.d2) as d2, count(1) as n
from 
(
select uid, gender, age, prov_id, 
lag(spot1,1,0) over (partition by uid order by stime) as spot0,
spot1,
lead(spot1,1,0) over (partition by uid order by stime) as spot2,
lag(dtime,1,0) over (partition by uid order by stime) as d0,
dtime as d1,
lead(dtime,1,0) over (partition by uid order by stime) as d2
from temp_ld20180717_table2
) x
group by x.prov_id, x.spot1, x.spot2;

select x.prov_id, x.spot0, x.spot1, x.spot2, 
sum(x.d0) as d0, sum(x.d1) as d1, sum(x.d2) as d2, count(1) as n
from 
(
select uid, gender, age, prov_id, 
lag(spot1,1,0) over (partition by uid order by stime) as spot0,
spot1,
lead(spot1,1,0) over (partition by uid order by stime) as spot2,
lag(dtime,1,0) over (partition by uid order by stime) as d0,
dtime as d1,
lead(dtime,1,0) over (partition by uid order by stime) as d2
from temp_ld20180717_table2
) x
group by x.prov_id, x.spot0, x.spot1, x.spot2;

select city_code, min(ext_min_x) as slon, min(ext_min_y) as slat,
avg(ext_max_x-ext_min_x) as mlon, avg(ext_max_y-ext_min_y) as mlat
from ss_grid_wgs84
where city_code = 'V0310000' 
group by city_code
