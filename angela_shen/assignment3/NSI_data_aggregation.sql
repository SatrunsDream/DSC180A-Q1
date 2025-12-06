DROP TABLE `week-8-assignment-478604.Capstone2025.h3_data`;

CREATE TABLE `week-8-assignment-478604.Capstone2025.h3_data` AS 

WITH structures AS

# Obtain property characteristics .csv file and import to BQ table.
  (
    SELECT * FROM `week-8-assignment-478604.Capstone2025.NSI_land`
  ),

h3_lc_data AS (
  SELECT lc.county_fips_code, 
  structures.st_damcat, structures.bldgtype, structures.num_story, structures.sqft, structures.val_struct, structures.cc,
  COUNT(*) AS counts

  FROM structures

  JOIN `week-8-assignment-478604.Capstone2025.h3_landcover` AS lc

  ON lc.h3_lc_id = structures.h3

  GROUP BY lc.county_fips_code, 
  structures.st_damcat, structures.bldgtype, structures.num_story, structures.sqft, structures.val_struct, structures.cc
),
-- 

-- h3_count_totals AS (
--   SELECT lc.county_fips_code, COUNT(*) AS totals

--   FROM h3_lc_data AS lc

--   GROUP BY lc.county_fips_code
-- ),

-- relative_freq AS (
--   SELECT lc.county_fips_code, 
--   lc.st_damcat, lc.bldgtype, lc.num_story, lc.sqft, lc.val_struct, lc.cc,
--   lc.counts / h3_count.totals AS counts

--   FROM h3_lc_data AS lc

--   JOIN h3_count_totals as h3_count

--   ON lc.county_fips_code = h3_count.county_fips_code
-- ),
  
cnty_roi AS

  (

    select *, county_geom as geometry

    from `bigquery-public-data.geo_us_boundaries.counties`

    # LIMIT 10
    WHERE state_fips_code = '06'

  ),

neighboring_counties AS (

 SELECT c1.geometry AS geometry, c1.county_fips_code AS county_code, c2.county_fips_code AS neighbors_code

 FROM cnty_roi AS c1

 JOIN cnty_roi AS c2

 ON ST_INTERSECTS(c1.geometry, c2.geometry) AND (c1.county_fips_code != c2.county_fips_code)

),

# get absolute difference 
# change which rows and structs are commented in order to instead sort by relative counts

delta AS (SELECT county_code, AVG(ABS(lc1.counts - lc2.counts)) AS deltas

FROM neighboring_counties AS nc

JOIN h3_lc_data AS lc1
# JOIN relative_freq AS lc1

ON lc1.county_fips_code = county_code

JOIN h3_lc_data AS lc2
# JOIN relative_freq AS lc2

ON lc2.county_fips_code = neighbors_code

GROUP BY county_code

ORDER BY deltas DESC
)

SELECT cnty_roi.geometry AS geometry, delta.deltas AS deltas

FROM delta

JOIN cnty_roi

ON cnty_roi.county_fips_code = delta.county_code

