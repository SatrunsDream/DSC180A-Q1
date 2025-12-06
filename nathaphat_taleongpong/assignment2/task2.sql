create table `capstone-477405.Capstone2025.StructureClusters` as
(
  select *, st_clusterdbscan(location, 400, 50) OVER () as cluster_id from `capstone-477405.Capstone2025.TestStructuresWithH3`
);
