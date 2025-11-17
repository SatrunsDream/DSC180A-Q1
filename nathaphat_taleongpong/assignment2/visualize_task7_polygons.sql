-- select
--   cluster_id,
--   h3,
--   structure_count,
--   cell_boundary as geometry
-- from `capstone-477405.Capstone2025.ClusterH3Cells`;

select
  level,
  polygon_id,
  total_structures,
  geometry
from `capstone-477405.Capstone2025.DensityPolygonsMerged`;
