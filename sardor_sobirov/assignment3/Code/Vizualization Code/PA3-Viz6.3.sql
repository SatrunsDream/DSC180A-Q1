-- See actual percent difference values
select 
  c.county_name,
  round(avg(p.pct_diff_content_cost), 2) as avg_pct_diff,
  round(min(p.pct_diff_content_cost), 2) as min_pct_diff,
  round(max(p.pct_diff_content_cost), 2) as max_pct_diff,
  sum(p.total_structures) as total_structures
from `capstone2025.CA_PropertyStats_Comparison` p
join `bigquery-public-data.geo_us_boundaries.counties` c
  on cast(p.fips as int64) = cast(c.county_fips_code as int64)
group by c.county_name
order by abs(avg(p.pct_diff_content_cost)) desc
limit 30;