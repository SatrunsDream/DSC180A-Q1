# drop table `cpastone-476406.capstone2025.SanDiegoStructuresInput`;
create table `cpastone-476406.capstone2025.SanDiegoStructuresInput` cluster by location as # why cluster?
(
  # cnty_roi and bldgs are two 'cte's ('common table expressions') used to break down complicated queries.
  # what do you think cnty_roi does?
  with cnty_roi as
  (
    select county_fips_code as fips, county_geom as geometry
    from `bigquery-public-data.geo_us_boundaries.counties`
    where county_fips_code = '06073'  -- san diego county
  ),
  bldgs as
  (
    select cnty.fips, bldg.id, bldg.level, bldg.class, bldg.has_parts, bldg.is_underground, bldg.geometry
    from `bigquery-public-data.overture_maps.building` bldg
    join cnty_roi cnty on st_intersects(bldg.geometry, cnty.geometry)  # what does this join do?
  ),
  filtered_bldgs as
  (
    select * except(is_underground),
           st_centroid(geometry) as centroid,
           st_buffer(geometry, -2, 3) as buff_geom
    from bldgs
    where is_underground = false and class = 'house' # more filtering to create small working subset
  )
  # final query - what is difference between centroid and location?
  select * except(centroid, buff_geom),
         st_closestpoint(buff_geom, centroid) as location
  from filtered_bldgs
  where not st_isempty(buff_geom) # what is the effect of this?
);
# drop table `cpastone-476406.capstone2025.SanDiegoStructures`;

create table `cpastone-476406.capstone2025.SanDiegoStructures` cluster by geometry as
(
  with bldgs as
  (
    # what does it look like the purpose of this cte is?
    select bldg.id, bldg2.id as id2
    from `cpastone-476406.capstone2025.SanDiegoStructuresInput` bldg
    join `cpastone-476406.capstone2025.SanDiegoStructuresInput` bldg2
      on st_intersects(bldg.location, bldg2.geometry)
    qualify 1 = row_number() over (partition by bldg.id order by abs(bldg2.level), st_area(bldg2.geometry) desc)
  )
  select bldg.*
  from `cpastone-476406.capstone2025.SanDiegoStructuresInput` bldg
  join bldgs bb
    on bldg.id = bb.id2 # is it correct to join bb.id2 instead of bb.id? what would happen if we joined bb.id?
);





















