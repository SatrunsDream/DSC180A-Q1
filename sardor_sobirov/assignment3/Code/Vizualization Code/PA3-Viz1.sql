SELECT
  county_geom AS geometry,
  county_fips_code AS fips,
  county_name
FROM `bigquery-public-data.geo_us_boundaries.counties`
WHERE state_fips_code = '06';