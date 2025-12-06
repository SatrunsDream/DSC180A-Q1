with county_stats as (
  select 
    fips,
    sum(total_structures) as total_structures,
    sum(mean_content_cost * total_structures) / sum(total_structures) 
      as mean_content_cost
  from `capstone2025.CA_PropertyStats_Summary`
  where land_cover_subtype = 'urban'
  group by fips
)

select
  min(mean_content_cost) as min_mean_content_cost,
  max(mean_content_cost) as max_mean_content_cost
from county_stats;