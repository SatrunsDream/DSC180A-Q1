with county_stats as (
  select 
    fips,
    land_cover_subtype,
    sum(total_structures) as total_structures,
    sum(mean_content_cost * total_structures) / sum(total_structures) 
      as weighted_mean_content_cost
  from `capstone2025.CA_PropertyStats_Summary`
  where land_cover_subtype in ('urban', 'forest', 'shrub')
  group by fips, land_cover_subtype
)

select
  c.county_name,
  cs.fips,
  cs.land_cover_subtype,
  cs.weighted_mean_content_cost as mean_content_cost,
  c.county_geom as geometry
from county_stats cs
join `bigquery-public-data.geo_us_boundaries.counties` c
  on cs.fips = c.county_fips_code
where c.state_fips_code = '06';


