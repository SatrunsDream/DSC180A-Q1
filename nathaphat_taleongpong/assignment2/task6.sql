create table `capstone-477405.Capstone2025.DensityPolygonsMerged` as
(
  with unioned_polygons as
  (
	select level, st_union_agg(geometry) as geometry from `capstone-477405.Capstone2025.DensityPolygonsWithBuffers` group by level
  ),
  dump_polygons as
  (
    select level, row_number() over (partition by level order by st_area(polygon_geometry) desc) as polygon_id, polygon_geometry as geometry from unioned_polygons, unnest(st_dump(geometry)) as polygon_geometry
  )
  select d.level, d.polygon_id, count(s.id) as total_structures, any_value(d.geometry) as geometry
  from dump_polygons d
  left join `capstone-477405.Capstone2025.StructureClusters` s
  on st_intersects(d.geometry, s.location)
  group by d.level, d.polygon_id
);
