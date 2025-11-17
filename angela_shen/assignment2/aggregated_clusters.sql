# 2: Use st_clusterdbscan and structure locations to classify locations within dense clusters.
WITH clusters AS (
  SELECT *, ST_CLUSTERDBSCAN(location, 400, 50) OVER () AS cluster_id
  FROM `week-6-assignment-477317.Capstone2025.TestStructuresWithH3`
),

# 3: For each cluster, obtain the H3 IDs that include a point classified as high density.

# Discard any cluster with fewer than 10 cells. 
cluster_counts AS (
  SELECT clusters.cluster_id, clusters.h3_lvl9, COUNT(*) AS cluster_count
  FROM clusters
  WHERE clusters.cluster_id IS NOT NULL
  GROUP BY clusters.cluster_id, clusters.h3_lvl9
  #HAVING COUNT(*) >= 10
  QUALIFY COUNT(*) OVER (PARTITION BY clusters.cluster_id) >= 10
),

#Also obtain cell boundary and count of structures
#in each cell
cell_boundaries AS (
  SELECT cluster_id, h3_lvl9, bqcarto.h3.ST_BOUNDARY(h3_lvl9) 
  AS cell_boundary, cluster_count 
  FROM cluster_counts
),
# 4: Vectorize H3 cells using st_union_agg.  Try to smooth with 'closing'/'opening' operations (using
# st_buffer) and st_simplify.
smoothed AS(
  SELECT cluster_id, ST_SIMPLIFY(ST_BUFFER(ST_BUFFER(ST_UNION_AGG(cell_boundary), 50), -50), 100) AS agg_cells FROM cell_boundaries
  GROUP BY cluster_id
),

# 5: Obtain distance to high density polygons at .4, 1, and 2.5 km.  Hint: Keep a ‘level’ attribute

# for these, where original is level 1, and these next three are 2, 3, & 4.

multilevel AS (
SELECT 1 AS level, cluster_id, agg_cells AS polygon FROM smoothed

UNION ALL

SELECT 2 AS level, cluster_id, ST_BUFFER(agg_cells, 400) AS polygon
FROM smoothed

UNION ALL

SELECT 3 AS level, cluster_id, ST_BUFFER(agg_cells, 1000) AS polygon
FROM smoothed

UNION ALL

SELECT 4 AS level, cluster_id, ST_BUFFER(agg_cells, 2500) AS polygon
FROM smoothed
)
# 6: Merge overlapping polygons at the same level.  Hint: this requires st_union_agg for all geometries

# at the same level, followed by st_dump to separate each polygon again.  Update property counts!

SELECT level, ST_UNION_AGG(polygon) AS polygons
FROM multilevel
GROUP BY level

# 7: Visualize your results by showing maps: h3 cell boundaries,

#    polygon map with .15 opacity, showing darker to lighter from dense to farthest from dense.
