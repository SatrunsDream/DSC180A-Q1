-- drop table `capstone-477405.Capstone2025.CALandCoverH3`;
create table `capstone-477405.Capstone2025.CALandCoverH3` as
select
  ca.county_fips as county_fips,
  lc.id as land_cover_id,
  lc.subtype as land_cover_type,
  h3_cell_id
from
  `capstone-477405.Capstone2025.CACounties` ca
join (
  select id, subtype, geometry, bbox
  from `bigquery-public-data.overture_maps.land_cover`
--  values are from the table after checking the xmax, xmin, ymax, ymin values
  where
    bbox.xmax >= -124.48200299999991
    and bbox.xmin <= -114.13121099999988
    and bbox.ymax >= 32.528831999999966
    and bbox.ymin <= 42.009503000000024
) lc
on st_intersects(ca.county_geom, lc.geometry),
unnest(bqcarto.h3.ST_ASH3_POLYFILL(st_intersection(ca.county_geom, lc.geometry), 9)) as h3_cell_id;