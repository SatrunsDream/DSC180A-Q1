#2
SELECT
  cluster_id,
  location AS geometry
FROM `cpastone-476406.capstone2025.StructureClusters`;

#3
SELECT
  cluster_id,
  h3_id,
  n_structures,
  h3_geom AS geometry
FROM `cpastone-476406.capstone2025.ClusterCells`;

#4
SELECT
  cluster_id,
  level,
  polygon AS geometry
FROM `cpastone-476406.capstone2025.Polygon`;

#6
SELECT
  level,
  geom AS geometry
FROM `cpastone-476406.capstone2025.CleanDistancePolygons`;