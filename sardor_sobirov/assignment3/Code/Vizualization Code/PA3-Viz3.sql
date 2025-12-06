select 
  fips,
  land_cover_subtype,
  h3_cell,
  h3_boundary as geometry
from `capstone2025.CA_CountyLandCover_H3`
where fips = '06073' 
limit 10000;  