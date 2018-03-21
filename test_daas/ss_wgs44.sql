create table lc_grid_map as
select city_code, city_name, min(ext_min_x) as minx, min(ext_min_y) as miny, avg(ext_max_x - ext_min_x) as avgx, avg(ext_max_y - ext_min_y) as avgy from ss_grid_wgs84 group by city_code, city_name;
