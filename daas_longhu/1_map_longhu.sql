create table map_longhu as
select city_code, min(ext_min_x) as slon, min(ext_min_y) as slat,
avg(ext_max_x-ext_min_x) as mlon, avg(ext_max_y-ext_min_y) as mlat
from ss_grid_wgs84
group by city_code
;

select city_code, slon, slat, mlon, mlat from map_longhu;
