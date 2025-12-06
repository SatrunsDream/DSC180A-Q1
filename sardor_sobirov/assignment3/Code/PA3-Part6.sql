create or replace table `capstone2025.CA_PropertyStats_Comparison` as
with county_stats as (
  select 
    fips,
    land_cover_subtype,
    damage_category,
    building_type,
    mean_content_cost,
    median_content_cost,
    total_structures,
    structures_per_cell
  from `capstone2025.CA_PropertyStats_Summary`
),
neighbor_stats as (
  -- Get average stats
  select 
    n.county_fips as fips,
    cs.land_cover_subtype,
    cs.damage_category,
    cs.building_type,
    avg(cs.mean_content_cost) as neighbor_avg_content_cost,
    avg(cs.median_content_cost) as neighbor_median_content_cost,
    avg(cs.structures_per_cell) as neighbor_avg_density,
    count(distinct n.neighbor_fips) as neighbor_count
  from `capstone2025.CA_CountyNeighbors` n
  join county_stats cs
    on cast(n.neighbor_fips as int64) = cast(cs.fips as int64)
  group by n.county_fips, cs.land_cover_subtype, cs.damage_category, cs.building_type
)
select 
  c.fips,
  c.land_cover_subtype,
  c.damage_category,
  c.building_type,
  c.mean_content_cost,
  c.median_content_cost,
  c.total_structures,
  c.structures_per_cell,
  
  -- Neighbor averages
  n.neighbor_avg_content_cost,
  n.neighbor_median_content_cost,
  n.neighbor_avg_density,
  n.neighbor_count,
  
  -- Calculate differences
  c.mean_content_cost - n.neighbor_avg_content_cost as delta_mean_content_cost,
  c.median_content_cost - n.neighbor_median_content_cost as delta_median_content_cost,
  c.structures_per_cell - n.neighbor_avg_density as delta_density,
  
  -- Calculate percent differences
  safe_divide(c.mean_content_cost - n.neighbor_avg_content_cost, n.neighbor_avg_content_cost) * 100 as pct_diff_content_cost,
  safe_divide(c.structures_per_cell - n.neighbor_avg_density, n.neighbor_avg_density) * 100 as pct_diff_density
  
from county_stats c
join neighbor_stats n
  on cast(c.fips as int64) = cast(n.fips as int64)
  and c.land_cover_subtype = n.land_cover_subtype
  and c.damage_category = n.damage_category
  and c.building_type = n.building_type
where n.neighbor_count > 0; 