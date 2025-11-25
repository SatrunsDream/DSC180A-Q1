
create table `capstone-477405.Capstone2025.DensityPolygonsWithBuffers` as
(
  with base as
  (
    select cluster_id, total_structures, geometry
    from `capstone-477405.Capstone2025.DensityPolygons`
  )
  -- lvl 1 original
  select cluster_id, 1 as level, total_structures, geometry
  from base
  union all
--   lvl 2
  select cluster_id, 2 as level, total_structures, st_buffer(geometry, 400) as geometry from base
  union all
--   lvl 3
  select cluster_id, 3 as level, total_structures, st_buffer(geometry, 1000) as geometry from base
  union all
--   lvl 4
  select cluster_id, 4 as level, total_structures, st_buffer(geometry, 2500) as geometry from base
);
