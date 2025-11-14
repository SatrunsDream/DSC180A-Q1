#
# Assignment Stages:
# 1: Preprocess - create an input structure test set that includes an 'H3' ID for the cell regions
#    you will use to build a polygon around high density.  We use H3 hex cells to make nice maps,
#    but other cells such as geohashes or S2 cells would also work.  Modify the above 'TestStructures'
#    query to include your region ID (H3 ID) for each location at level 8 and 9.
# 2: Use st_clusterdbscan and structure locations to classify locations within dense clusters.
# 3: For each cluster, obtain the H3 IDs that include a point classified as high density.
#    Discard any cluster with fewer than 10 cells.  Also obtain cell boundary and count of structures
#    in each cell.  Hint: When getting H3 IDs for cluster, use ‘group by’ on cluster ID and H3 ID.
#    Then ‘count(*)’ will give you number of structures, and you will have cell boundary only once per cell.
#    Be sure to ignore structures in ‘null’ cluster!
# 4: Vectorize H3 cells using st_union_agg.  Try to smooth with 'closing'/'opening' operations (using
#    st_buffer) and st_simplify.
# 5: Obtain distance to high density polygons at .4, 1, and 2.5 km.  Hint: Keep a ‘level’ attribute
#    for these, where original is level 1, and these next three are 2, 3, & 4.
# 6: Merge overlapping polygons at the same level.  Hint: this requires st_union_agg for all geometries
#    at the same level, followed by st_dump to separate each polygon again.  Update property counts!
# 7: Visualize your results by showing maps: h3 cell boundaries,
#    polygon map with .15 opacity, showing darker to lighter from dense to farthest from dense.
#
 


#2 
create table `cpastone-476406.capstone2025.StructureClusters` as
select *, ST_CLUSTERDBSCAN(location, 400, 50) OVER () as cluster_id
from `cpastone-476406.capstone2025.TestStructuresWithH3`;
#3
#drop table `cpastone-476406.capstone2025.ClusterCells`
create table `cpastone-476406.capstone2025.ClusterCells` as
with base as (
  select
    cluster_id,
    h3_lvl9 as h3_id,
    count(*) as n_structures
  from `cpastone-476406.capstone2025.StructureClusters`
  where cluster_id is not null -- ignore noise
  group by cluster_id, h3_id
  qualify count(*) over (partition by cluster_id) >= 10
)
select
  cluster_id,h3_id,
  bqcarto.h3.ST_BOUNDARY(h3_id) as h3_geom,
  n_structures
from base;
  
#4
#drop table `cpastone-476406.capstone2025.Polygon`
create TABLE `cpastone-476406.capstone2025.Polygon` AS
SELECT
  cluster_id,
  1 AS level,
  ST_SIMPLIFY(
    ST_BUFFER(
      ST_BUFFER(ST_UNION_AGG(h3_geom), 50),-50),25) 
      AS polygon
FROM `cpastone-476406.capstone2025.ClusterCells`
GROUP BY cluster_id;

#5
#drop table `cpastone-476406.capstone2025.DistancePolygons`
create TABLE `cpastone-476406.capstone2025.DistancePolygons` AS
WITH base AS (
  SELECT
    cluster_id, polygon AS geom
  FROM `cpastone-476406.capstone2025.Polygon`
)
SELECT
  cluster_id, 1 AS level, geom
FROM base

UNION ALL
SELECT
  cluster_id, 2 AS level, ST_BUFFER(geom, 400)      
FROM base

UNION ALL
SELECT
  cluster_id, 3 AS level, ST_BUFFER(geom, 1000)     
FROM base

UNION ALL
SELECT
  cluster_id, 4 AS level, ST_BUFFER(geom, 2500)     
FROM base;

#6
CREATE TABLE `cpastone-476406.capstone2025.CleanDistancePolygons` AS
SELECT
  level,
  ST_SIMPLIFY(
    ST_UNION_AGG(geom),   
    50                
  ) AS geom
FROM `cpastone-476406.capstone2025.DistancePolygons`
GROUP BY level;


