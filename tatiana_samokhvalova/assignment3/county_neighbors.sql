# step 1
create or replace table `capstonew4.Capstone2025.county_neighbors` as

with counties as (
  select cast(county_fips_code as int64) as fips, county_geom as geom
  from `bigquery-public-data.geo_us_boundaries.counties`
  where cast(county_fips_code as int64) in (select distinct fips from `capstonew4.Capstone2025.NSI_Data`)
)

select c1.fips as county, c2.fips as neighbor
from counties c1
join counties c2 on ST_Touches(c1.geom, c2.geom)
where c1.fips != c2.fips