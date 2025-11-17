
create table `velvety-rookery-464021-d5.capstone_2025.capstone_2025` cluster by location as # Why cluster?
(
  # cnty_roi and bldgs are two 'CTE's ('common table expressions') used to break down complicated queries.
  # What do you think cnty_roi does?
  with cnty_roi as
  (
    select county_fips_code as fips, county_geom as geometry from `bigquery-public-data.geo_us_boundaries.counties`
    where county_fips_code = '06073'
  ),
  bldgs as
  (
    select cnty.fips, bldg.id, bldg.level, bldg.class, bldg.has_parts, bldg.is_underground, bldg.geometry
    from `bigquery-public-data.overture_maps.building` bldg
    -- TABLESAMPLE SYSTEM (0.1 PERCENT)
    join cnty_roi cnty on st_intersects(bldg.geometry, cnty.geometry)  # What does this join do?
  ),
  filtered_bldgs as
  (
    select * except(is_underground), st_centroid(geometry) as centroid, st_buffer(geometry, -2, 3) as buff_geom
    from bldgs where is_underground = false and class = 'house' # More filtering to create small working subset
  )
  # Final query - what is difference between centroid and location?
  select * except(centroid, buff_geom), st_closestpoint(buff_geom, centroid) as location
  from filtered_bldgs
  where not (st_isempty(buff_geom)) # What is the effect of this?
)

