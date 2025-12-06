
# Obtain neighbor counties for each county in area of interest.
# Generate land cover regions within each county.

DROP TABLE `week-8-assignment-478604.Capstone2025.landcover`;

CREATE TABLE `week-8-assignment-478604.Capstone2025.landcover` AS 

with cnty_roi as

  (

    select *, county_geom as geometry

    from `bigquery-public-data.geo_us_boundaries.counties`

    WHERE state_fips_code = '06'

    # LIMIT 10

  ),

  CA_boundary AS (
    SELECT geometry AS ca_geometry

    FROM `bigquery-public-data.overture_maps.land_cover` as lc

    WHERE ST_INTERSECTS(lc.geometry, ST_GeogFromText('POLYGON((-124.41060660766607 32.5342307609976, -114.13445790587905 32.5342307609976, -114.13445790587905 42.00965914828148, -124.41060660766607 42.00965914828148, -124.41060660766607 32.5342307609976))'))
  )

SELECT county_fips_code, ST_INTERSECTION(lc.ca_geometry, cnty_roi.geometry) AS landcover

FROM cnty_roi

JOIN CA_boundary as lc

ON ST_INTERSECTS(lc.ca_geometry, cnty_roi.geometry);


# Obtain H3 cells by land cover region in each county.

DROP TABLE `week-8-assignment-478604.Capstone2025.h3_landcover`;

CREATE TABLE `week-8-assignment-478604.Capstone2025.h3_landcover` AS 

SELECT county_fips_code, landcover, bqcarto.h3.ST_BOUNDARY(h3_id) AS h3_geom, h3_id AS h3_lc_id

FROM `week-8-assignment-478604.Capstone2025.landcover`, UNNEST(bqcarto.h3.ST_ASH3_POLYFILL(landcover, 9)) AS h3_id

WHERE landcover IS NOT NULL;
