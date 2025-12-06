create table `capstone2025.CA_CountyNeighbors` as
with ca as (
  select county_fips_code as fips, county_geom
  from `bigquery-public-data.geo_us_boundaries.counties`
  where state_fips_code = '06'
)
select 
  a.fips as county_fips,
  b.fips as neighbor_fips
from ca a
join ca b
  on st_touches(a.county_geom, b.county_geom)
where a.fips != b.fips;
