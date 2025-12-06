-- 1. Structure count by land cover type (bar chart)
select 
  land_cover_subtype,
  sum(structure_count) as total_structures
from `capstone2025.CA_PropertyStats_ByLandCover`
group by land_cover_subtype
order by total_structures desc;

-- 2. Building types by land cover (stacked bar)
select 
  land_cover_subtype,
  bldgtype,
  sum(structure_count) as structure_count
from `capstone2025.CA_PropertyStats_ByLandCover`
group by land_cover_subtype, bldgtype
order by land_cover_subtype, structure_count desc;

