-- Check a specific county's comparison
select 
  p.fips,
  c.county_name,
  p.land_cover_subtype,
  p.building_type,
  p.mean_content_cost,
  p.neighbor_avg_content_cost,
  p.neighbor_count,
  p.delta_mean_content_cost,
  p.pct_diff_content_cost
from `capstone2025.CA_PropertyStats_Comparison` p
join `bigquery-public-data.geo_us_boundaries.counties` c
  on cast(p.fips as int64) = cast(c.county_fips_code as int64)
where c.county_name = 'San Diego'
  and p.land_cover_subtype = 'urban'
order by abs(p.pct_diff_content_cost) desc
limit 10;