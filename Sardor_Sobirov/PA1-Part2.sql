WITH structs AS (

  SELECT id, geometry
  FROM `cpastone-476406.capstone2025.SanDiegoStructuresInput`
  LIMIT 100
),
rings AS (
  SELECT
    id,
    ST_ExteriorRing(geometry) AS ring,
    ST_NumPoints(ST_ExteriorRing(geometry)) AS n
  FROM structs
),
vertexs AS (
  SELECT
    id,ring,n,i,
    ST_PointN(ring, i) AS curr,
    ST_PointN(ring, CASE WHEN i = 1 THEN n - 1 ELSE i - 1 END) AS prev,
    ST_PointN(ring, CASE WHEN i = n - 1 THEN 1 ELSE i + 1 END) AS nxt
  FROM rings, UNNEST(GENERATE_ARRAY(1, n - 1)) AS i
),
angles AS (
  SELECT
    id,curr AS vertex,
    ST_Angle(prev, curr, nxt) AS angle_rad
  FROM vertexs
)
SELECT id, ST_Buffer(vertex, 0.5) AS geometry
FROM angles
WHERE angle_rad > ACOS(-1); 


