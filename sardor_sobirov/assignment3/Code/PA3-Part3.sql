drop table if exists `capstone2025.CA_CountyLandCover_H3`;

create table `capstone2025.CA_CountyLandCover_H3` as
select 
  fips,
  land_cover_subtype,
  cast(h3_cell as string) as h3_cell,
  bqcarto.h3.ST_BOUNDARY(h3_cell) as h3_boundary
from `capstone2025.CA_CountyLandCover`,
unnest(bqcarto.h3.ST_ASH3_POLYFILL(geom, 9)) as h3_cell  
where not st_isempty(geom);