create table `capstone2025.CA_CountyLandCover` as
with ca as (
  select county_fips_code as fips, county_geom
  from `bigquery-public-data.geo_us_boundaries.counties`
  where state_fips_code = '06'
),
ca_land_cover as (
  -- Pre-filter using bbox struct (faster than geometry intersection)
  select subtype, geometry
  from `bigquery-public-data.overture_maps.land_cover`
  where bbox.xmax >= -124.41 
    and bbox.xmin <= -114.13
    and bbox.ymax >= 32.53
    and bbox.ymin <= 42.01
)
select
  ca.fips,
  lc.subtype as land_cover_subtype,
  st_intersection(ca.county_geom, lc.geometry) as geom
from ca
join ca_land_cover lc
  on st_intersects(ca.county_geom, lc.geometry)
where not st_isempty(st_intersection(ca.county_geom, lc.geometry));
