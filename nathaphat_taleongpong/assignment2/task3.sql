create table `capstone-477405.Capstone2025.ClusterH3Cells` as
(
  with cluster_h3_counts as
  (
    select 
      cluster_id,
      h3_lvl9 as h3,
      count(*) as structure_count,
      bqcarto.h3.ST_BOUNDARY(h3_lvl9) as cell_boundary
    from `capstone-477405.Capstone2025.StructureClusters`
    where cluster_id is not null
    group by cluster_id, h3_lvl9
  ),
  cluster_cell_counts as
  (
    select 
      cluster_id,
      count(distinct h3) as total_cells
    from cluster_h3_counts
    group by cluster_id
  )
  select 
    c.cluster_id,
    c.h3,
    c.structure_count,
    c.cell_boundary
  from cluster_h3_counts c
  join cluster_cell_counts cc on c.cluster_id = cc.cluster_id
  where cc.total_cells >= 10
);
