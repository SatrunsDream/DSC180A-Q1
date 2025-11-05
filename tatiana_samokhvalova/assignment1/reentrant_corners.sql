with structs as (
  select *, ST_GEOMETRYTYPE(geometry) from `capstonew4.Capstone2025.SanDiegoStructures` 
  where ST_GEOMETRYTYPE(geometry) = 'ST_Polygon'
  --limit 1
),
vertices as (
  select 
    id,
    vertex_num,
    ST_POINTN(ST_EXTERIORRING(geometry), vertex_num) as vertex_point
  from structs,
  UNNEST(GENERATE_ARRAY(1, ST_NUMPOINTS(ST_EXTERIORRING(geometry)))) as vertex_num
  
  UNION ALL
  
  select
    id,
    ST_NUMPOINTS(ST_EXTERIORRING(geometry)) + 1 as vertex_num,
    ST_POINTN(ST_EXTERIORRING(geometry), 2) as vertex_point
  from structs
),

corners as (
  select
    v.id,
    v.vertex_num,
    v_prev.vertex_point as prev_vertex,
    v.vertex_point as cur_vertex,
    v_next.vertex_point as next_vertex
  from vertices v
  join vertices v_prev 
    on v.id = v_prev.id and v.vertex_num = v_prev.vertex_num + 1
  join vertices v_next 
    on v.id = v_next.id and v.vertex_num = v_next.vertex_num - 1
),

angles as (
  select 
    c.id,
    c.cur_vertex,
    c.vertex_num,
    st_angle(prev_vertex, cur_vertex, next_vertex) angle_rad,
    st_angle(prev_vertex, cur_vertex, next_vertex) * 180 / 3.14159 angle_deg
  from corners c
)

select * from angles
where angles.angle_deg > 180
