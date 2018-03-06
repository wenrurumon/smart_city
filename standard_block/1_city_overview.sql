DROP TABLE IF EXISTS geo_range;
create table geo_range as
select min(weighted_centroid_lat) as minlat,
min(weighted_centroid_lon) as minlon,
max(weighted_centroid_lat) as maxlat,
max(weighted_centroid_lon) as maxlon
from stay_poi
where date = 20170901 and city = 'V0110000';

