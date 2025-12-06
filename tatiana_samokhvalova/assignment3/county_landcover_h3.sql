# step 2
create or replace table `capstonew4.Capstone2025.county_landcover_h3` as

with counties as (
  select cast(county_fips_code as int64) as fips, county_geom as geom
  from `bigquery-public-data.geo_us_boundaries.counties`
  where cast(county_fips_code as int64) in (select distinct fips from `capstonew4.Capstone2025.NSI_Data`)
),

land_cover_regions as (
  with ca_poly as (
    select st_union_agg(geom) as geom
    from counties
  ),
  ca_land_cover as (
    select * from `bigquery-public-data.overture_maps.land_cover` lc
    join ca_poly p on ST_INTERSECTS(p.geom, lc.geometry) 
  )
  select c.fips, lc.subtype, ST_INTERSECTION(c.geom, lc.geometry) as geom
  from counties c
  join ca_land_cover lc on ST_INTERSECTS(c.geom, lc.geometry)
)

select fips, subtype as land_cover_subtype, h3_lvl9
from
  land_cover_regions,
  unnest(bqcarto.h3.ST_ASH3_POLYFILL(geom, 9)) as h3_lvl9