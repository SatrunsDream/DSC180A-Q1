with structs as
(
  select * from `velvety-rookery-464021-d5.capstone_2025.capstone_2025`
  where ST_GEOMETRYTYPE(geometry) = 'ST_Polygon'
  LIMIT 1000
),
indices as
(
  select 
    id,
    geometry,
    idx
  from structs,
  UNNEST(GENERATE_ARRAY(1, ST_NUMPOINTS(ST_EXTERIORRING(geometry)) - 1)) as idx
),
vertices as
(
  select
    id,
    idx as vertex_index,
    ST_POINTN(ST_EXTERIORRING(geometry), idx) as vertex_point,
    ST_NUMPOINTS(ST_EXTERIORRING(geometry)) - 1 as total_points
  from indices
),
vertex_triplets as
(
  select
    v1.id,
    v1.vertex_index,
    v1.vertex_point as current_vertex,
    v0.vertex_point as prev_vertex,
    v2.vertex_point as next_vertex
  from vertices v1
  join vertices v0 on v1.id = v0.id 
    and v0.vertex_index = CASE WHEN v1.vertex_index = 1 THEN v1.total_points ELSE v1.vertex_index - 1 END
  join vertices v2 on v1.id = v2.id 
    and v2.vertex_index = CASE WHEN v1.vertex_index = v1.total_points THEN 1 ELSE v1.vertex_index + 1 END
)
select 
  id,
  vertex_index,
  ST_ANGLE(prev_vertex, current_vertex, next_vertex) as angle_radians,
  ST_ANGLE(prev_vertex, current_vertex, next_vertex) * 180 / ACOS(-1) as angle_degrees,
  current_vertex as reentrant_corner
from vertex_triplets
where ST_ANGLE(prev_vertex, current_vertex, next_vertex) > ACOS(-1)
order by id, vertex_index
