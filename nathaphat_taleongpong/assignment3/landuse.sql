-- drop table `capstone-477405.Capstone2025.CALandUseH3`;
create table `capstone-477405.Capstone2025.CALandUseH3` as
select
  ca.county_fips as county_fips,
  lu.id as land_use_id,
  lu.class as land_use_class,
  h3_cell_id
from
  `capstone-477405.Capstone2025.CACounties` ca
join (
  select id, class, geometry, bbox
  from `bigquery-public-data.overture_maps.land_use`
  --  values are from the table after checking the xmax, xmin, ymax, ymin values
  where
    bbox.xmax >= -124.48200299999991
    and bbox.xmin <= -114.13121099999988
    and bbox.ymax >= 32.528831999999966 
    and bbox.ymin <= 42.009503000000024
) lu
on st_intersects(ca.county_geom, lu.geometry),
unnest(bqcarto.h3.ST_ASH3_POLYFILL(st_intersection(ca.county_geom, lu.geometry), 9)) as h3_cell_id;