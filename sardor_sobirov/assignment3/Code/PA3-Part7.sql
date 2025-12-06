create or replace table `capstone2025.CA_PropertyStats_Ranked` as
select 
  fips,
  land_cover_subtype,
  damage_category,
  building_type,
  mean_content_cost,
  neighbor_avg_content_cost,
  delta_mean_content_cost,
  pct_diff_content_cost,
  structures_per_cell,
  neighbor_avg_density,
  delta_density,
  pct_diff_density,
  total_structures,
  neighbor_count,

  --ranks
  row_number() over (order by abs(pct_diff_content_cost) desc) as rank_by_cost_diff,
  row_number() over (order by abs(pct_diff_density) desc) as rank_by_density_diff,
  row_number() over (partition by land_cover_subtype order by abs(pct_diff_content_cost) desc) as rank_within_landcover,
  row_number() over (partition by building_type order by abs(pct_diff_content_cost) desc) as rank_within_buildingtype,
  --Combine
  abs(pct_diff_content_cost) + abs(pct_diff_density) as outlier_score,
  row_number() over (order by abs(pct_diff_content_cost) + abs(pct_diff_density) desc) as rank_by_outlier_score
  
from `capstone2025.CA_PropertyStats_Comparison`
where total_structures > 10; 