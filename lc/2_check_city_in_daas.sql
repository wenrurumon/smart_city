select sp.city, sp.date, m.city_name
from ss_grid_wgs84 m inner join stay_poi sp
on m.city_code = sp.city
group by sp.city, sp.date, m.city_name;
