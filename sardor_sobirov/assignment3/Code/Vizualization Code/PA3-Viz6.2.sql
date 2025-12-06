-- Counties with unusual building type mixes
with county_building_dist as (
  select 
    fips,
    building_type,
    sum(total_structures) as structures,
    sum(total_structures) / sum(sum(total_structures)) over (partition by fips) as pct_of_county
  from `capstone2025.CA_PropertyStats_Summary`
  group by fips, building_type
),
neighbor_building_dist as (
  select 
    n.county_fips as fips,
    cbd.building_type,
    avg(cbd.pct_of_county) as neighbor_avg_pct
  from `capstone2025.CA_CountyNeighbors` n
  join county_building_dist cbd
    on cast(n.neighbor_fips as int64) = cast(cbd.fips as int64)
  group by n.county_fips, cbd.building_type
)
select 
  c.county_name,
  cbd.building_type,
  round(cbd.pct_of_county * 100, 2) as pct_of_buildings,
  round(nbd.neighbor_avg_pct * 100, 2) as neighbor_avg_pct,
  round((cbd.pct_of_county - nbd.neighbor_avg_pct) * 100, 2) as pct_point_difference
from county_building_dist cbd
join neighbor_building_dist nbd
  on cast(cbd.fips as int64) = cast(nbd.fips as int64)
  and cbd.building_type = nbd.building_type
join `bigquery-public-data.geo_us_boundaries.counties` c
  on cast(cbd.fips as int64) = cast(c.county_fips_code as int64)
order by abs(cbd.pct_of_county - nbd.neighbor_avg_pct) desc
limit 30;