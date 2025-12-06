select 
  c.county_name,
  p.land_cover_subtype,
  p.mean_content_cost,
  c.county_geom as geometry
from `capstone2025.CA_PropertyStats_Summary` p
join `bigquery-public-data.geo_us_boundaries.counties` c
  on cast(p.fips as int64) = cast(c.county_fips_code as int64)
where land_cover_subtype = 'urban'; 