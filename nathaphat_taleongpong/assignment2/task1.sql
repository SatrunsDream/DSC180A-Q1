create table `capstone-477405.Capstone2025.TestStructuresWithH3` as
(
  with structures as
  (
    select * from `capstone-477405.Capstone2025.CAStructuresInput`
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
  select * except(rnd, centroid, buff_geom), st_closestpoint(buff_geom, centroid) as location,bqcarto.h3.ST_ASH3(st_closestpoint(buff_geom, centroid), 8) as h3_lvl8, bqcarto.h3.ST_ASH3(st_closestpoint(buff_geom, centroid), 9) as h3_lvl9
  from
  (
     # Can use row_number() or rand(), plus some filter, to reduce subset to desired size.
    select ss.*, st_buffer(ss.geometry, -2, 3) as buff_geom, row_number() over () as rnd # rand() as rnd,
    from subset ss
  )
  where not st_isempty(buff_geom) and mod(rnd, 2) = 0 # rnd < .5 # (When using 'rand()')
);
