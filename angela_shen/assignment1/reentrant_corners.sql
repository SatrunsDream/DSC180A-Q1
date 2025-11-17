with CTE_1 as (
# creates list from 1 - N where N is the number of vertices in the exterior ring of the polygon
  with structs as 
  (
  SELECT id, geometry, (GENERATE_ARRAY(1, ST_NUMPOINTS(ST_EXTERIORRING(geometry)))) AS point_id FROM `week-3-participation.Capstone2025.SanDiegoStructures` WHERE ST_GeometryType(geometry) = 'ST_Polygon'
  )
# unnests list and defines point id, as well as +/-1 for joining
SELECT id, geometry, point_ids AS pid_1, point_ids - 1 AS pid_2, point_ids + 1 AS pid_3, ST_POINTN(ST_EXTERIORRING(geometry), point_ids) AS points FROM structs, UNNEST(point_id) AS point_ids
), 
# self-join the original table to get sets of vertices for angle
struct_2 AS (
  # this was an attempt to get the max number of points in a polygon per each building id to try and add in the end points, but I wasn't quite able to get it to join correctly
  #WITH structs_1 AS (
  #  SELECT id, MAX(point_id) AS max_points FROM CTE_1 GROUP BY id
  #),
  #CTE_COPY AS (
  #  SELECT * FROM CTE_1 LEFT JOIN structs_1 ON structs_1.id = CTE_1.id
  #)
  # additionally, I tried to use -1 to get the starting points, but the cardinality is the same as the original table
  SELECT CTE_1.id, CTE_1.geometry, CTE_3.points AS point_1, CTE_1.points AS point_2, CTE_2.points AS point_3, FROM CTE_1
  FULL JOIN CTE_1 AS CTE_2
  ON (CTE_1.pid_1 = CTE_2.pid_2 OR CTE_2.pid_2 = -1) AND (CTE_1.id = CTE_2.id)
  INNER JOIN CTE_1 AS CTE_3
  ON (CTE_1.pid_1 = CTE_3.pid_3) AND CTE_1.id = CTE_3.id
),
# acquires the center point of the triangle representing the angle
# TO DO: calculate distance using convex hull instead
CTE_AGAIN AS (
  SELECT id, geometry, ST_CENTROID(ST_MAKELINE(point_1, point_3)) AS center, point_2
  FROM struct_2
)

# depth of concavity: Supposing we have vertices 1, 2, 3, with 2 being the intersection of 2 lines, find the centroid of vertices 1 and 2 and then find the distance between 2 and centroid
SELECT id, geometry, ST_DISTANCE(center, point_2) AS DEPTH, center
FROM CTE_AGAIN;

# calculate angle
# concave = >180 degrees?

#SELECT id, geometry, point_1, point_2, point_3, ST_ANGLE(point_1, point_2, point_3) AS angle
#FROM struct_2
#WHERE ST_ANGLE(point_1, point_2, point_3) > 3.14 AND ST_ANGLE(point_1, point_2, point_3) < 2 * 3.14;
