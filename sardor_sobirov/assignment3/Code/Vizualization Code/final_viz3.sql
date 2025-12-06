-- 
select 
  any_value(c.county_geom) as geometry,
  c.county_name,
  avg(r.pct_diff_density) as avg_pct_diff_density
from `bigquery-public-data.geo_us_boundaries.counties` c
left join `capstone2025.CA_PropertyStats_Ranked` r
  on cast(r.fips as int64) = cast(c.county_fips_code as int64)
where c.state_fips_code = '06'
group by c.county_name, c.county_fips_code;