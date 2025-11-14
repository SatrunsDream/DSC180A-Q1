create TABLE `cpastone-476406.capstone2025.CAStructuresInput`
CLUSTER BY centroid AS (
  WITH states AS (
    SELECT *, ST_SIMPLIFY(state_geom, 1000) AS simple_geom
    FROM `bigquery-public-data.geo_us_boundaries.states`
    WHERE state = 'CA'
  ),
  structures AS (
    SELECT
      bb.id,
      bb.level,
      bb.has_parts,
      bb.geometry,
      ST_CENTROID(bb.geometry) AS centroid
    FROM `bigquery-public-data.overture_maps.building` bb
    JOIN states ss
    ON ST_INTERSECTS(
      ss.simple_geom,
      ST_GEOGPOINT((bbox.xmin + bbox.xmax)/2, (bbox.ymin + bbox.ymax)/2)
    )
    WHERE is_underground = FALSE AND class = 'house'
  )
  SELECT * FROM structures
);

create table `cpastone-476406.capstone2025.TestStructures` as
(
  with structures as
  (
    select * from `cpastone-476406.capstone2025.CAStructuresInput`
  ),
  cnty_roi as
  (
    select county_fips_code as fips, county_geom as geometry
    from `bigquery-public-data.geo_us_boundaries.counties`
    where county_fips_code = '06073'
  ),
  subset as
  (
    select cnty.fips, ss.* from structures ss
    join cnty_roi cnty
    on st_intersects(cnty.geometry, ss.centroid)
  )
  select * except(rnd, centroid, buff_geom), st_closestpoint(buff_geom, centroid) as location from
  (
     # Can use row_number() or rand(), plus some filter, to reduce subset to desired size.
    select ss.*, st_buffer(ss.geometry, -2, 3) as buff_geom, row_number() over () as rnd # rand() as rnd,
    from subset ss
  )
  where not st_isempty(buff_geom) and mod(rnd, 2) = 0 # rnd < .5 # (When using 'rand()')
);



create table `cpastone-476406.capstone2025.TestStructuresWithH3` as
(
  with structures as
  (
    select * from `cpastone-476406.capstone2025.CAStructuresInput`
  ),
  cnty_roi as
  (
    select county_fips_code as fips, county_geom as geometry
    from `bigquery-public-data.geo_us_boundaries.counties`
    where county_fips_code = '06073'
  ),
  subset as
  (
    select cnty.fips, ss.* from structures ss
    join cnty_roi cnty
    on st_intersects(cnty.geometry, ss.centroid)
  )
  select * except(rnd, centroid, buff_geom), st_closestpoint(buff_geom, centroid) as location,
  bqcarto.h3.ST_ASH3(centroid, 8) as h3_lvl8, bqcarto.h3.ST_ASH3(centroid, 9) as h3_lvl9, from
  (
     # Can use row_number() or rand(), plus some filter, to reduce subset to desired size.
    select ss.*, st_buffer(ss.geometry, -2, 3) as buff_geom, row_number() over () as rnd # rand() as rnd,
    from subset ss
  )
  where not st_isempty(buff_geom) and mod(rnd, 2) = 0 # rnd < .5 # (When using 'rand()')
)