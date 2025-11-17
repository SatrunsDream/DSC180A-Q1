# stage 2
with clusters as (
  select 
    *,
    ST_CLUSTERDBSCAN(location, 400, 50) OVER () as cluster_id
  from `capstonew4.Capstone2025.TestStructuresWithH3`
),
# stage 3
filtered_clusters as (
  select cluster_id from clusters
  where cluster_id is not null
  group by cluster_id
  having count(distinct h3_lvl9) > 10
),
high_density_h3s as (
  select cluster_id, h3_lvl9, count(*), bqcarto.h3.ST_BOUNDARY(h3_lvl9) as cell_boundary
  from clusters
  where cluster_id in (select cluster_id from filtered_clusters)
  group by cluster_id, h3_lvl9
),
# stage 4
vectorized as (
    select 
    cluster_id,
    ST_SIMPLIFY(
      ST_BUFFER(ST_BUFFER(
        ST_BUFFER(ST_BUFFER(
          ST_UNION_AGG(cell_boundary), 
        200), -200), # this filled the gaps -- "closing"?
      -200), 200), # this makes it more smooth -- "opening"?
      50
    ) as cluster_geometry
  from high_density_h3s
  group by cluster_id
),
# stage 5
density_levels as (
  select 1 as level, cluster_id, cluster_geometry as polygon from vectorized
  UNION ALL
  select 2 as level, cluster_id, ST_BUFFER(cluster_geometry, 400) as polygon from vectorized
  UNION ALL
  select 3 as level, cluster_id, ST_BUFFER(cluster_geometry, 1000) as polygon from vectorized
  UNION ALL
  select 4 as level, cluster_id, ST_BUFFER(cluster_geometry, 2500) as polygon from vectorized
),
# stage 6
merged as (
  select level, st_union_agg(polygon) as merged_geom
  from density_levels
  group by level
  -- order by level desc
),
separated_polygons as (
  select level, geometry
  from merged,
  UNNEST(ST_DUMP(merged_geom)) as geometry
)
select * from separated_polygons
order by level desc
