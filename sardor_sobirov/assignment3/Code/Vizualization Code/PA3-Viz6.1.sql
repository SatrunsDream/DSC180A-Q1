select 
  c.county_name,
  p.fips,
  p.land_cover_subtype,
  p.building_type,
  p.mean_content_cost,
  p.neighbor_avg_content_cost,
  p.delta_mean_content_cost,
  p.pct_diff_content_cost,
  p.total_structures
from `capstone2025.CA_PropertyStats_Comparison` p
join `bigquery-public-data.geo_us_boundaries.counties` c
  on cast(p.fips as int64) = cast(c.county_fips_code as int64)
where p.total_structures > 50
order by abs(p.pct_diff_content_cost) desc
limit 20;