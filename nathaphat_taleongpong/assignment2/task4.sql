create table `capstone-477405.Capstone2025.DensityPolygons` as
(
  select 
    cluster_id,
    1 as level,
    sum(structure_count) as total_structures,
    st_simplify(st_buffer(st_buffer(st_union_agg(cell_boundary),50),-50), 10) as geometry
  from `capstone-477405.Capstone2025.ClusterH3Cells`
  group by cluster_id
);
