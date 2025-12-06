create or replace table `capstone2025.CA_PropertyStats_Summary` as
select 
  fips,
  land_cover_subtype,
  st_damcat as damage_category,
  bldgtype as building_type,
  
  -- Structure counts
  sum(structure_count) as total_structures,
  sum(h3_cell_count) as total_h3_cells,
  
  -- Content cost statistics
  avg(avg_content_cost) as mean_content_cost,
  approx_quantiles(avg_content_cost, 100)[offset(50)] as median_content_cost,
  stddev(avg_content_cost) as stddev_content_cost,
  min(avg_content_cost) as min_content_cost,
  max(avg_content_cost) as max_content_cost,
  
  
  sum(structure_count) / sum(h3_cell_count) as structures_per_cell
  
from `capstone2025.CA_PropertyStats_ByLandCover`
group by fips, land_cover_subtype, st_damcat, bldgtype
having total_structures > 10;  