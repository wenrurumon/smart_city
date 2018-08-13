select a.city_code, b.area_desc, b.prov_name, min(a.ext_min_x) as slon, min(a.ext_min_y) as slat,
avg(a.ext_max_x-ext_min_x) as mlon, avg(a.ext_max_y-ext_min_y) as mlat
from ss_grid_wgs84 a inner join area_code b
on a.city_code = b.area_id
group by a.city_code, b.area_desc, b.prov_name;
