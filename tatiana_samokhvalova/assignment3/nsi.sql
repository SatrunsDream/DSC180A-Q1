with counties as (
  select cast(county_fips_code as int64) as fips, county_geom as geom
  from `bigquery-public-data.geo_us_boundaries.counties`
  where cast(county_fips_code as int64) in (select distinct fips from `capstonew4.Capstone2025.NSI_Data`)
),

-- # neighbor counties
-- select c1.fips as county, c2.fips as neighbor
-- from counties c1
-- join counties c2 on ST_Touches(c1.geom, c2.geom)
-- where c1.fips != c2.fips

# land cover regions
land_cover_regions as (
  select c.fips, lc.subtype, ST_INTERSECTION(c.geom, lc.geometry) as geom
  from counties c
  join `bigquery-public-data.overture_maps.land_cover` lc on ST_INTERSECTS(c.geom, lc.geometry)
)
select * from land_cover_regions


# having issues here: using wrong function
-- select fips, subtype, h3_lvl8
-- from
--   land_cover_regions,
--   unnest(bqcarto.h3.ST_POLYFILL(geom, 8)) as h3_lvl8



-- select * from `capstonew4.Capstone2025.NSI_Data` limit 2