select 
  land_cover_subtype,
  sum(structure_count) as total_structures
from `capstone2025.CA_PropertyStats_ByLandCover`
group by land_cover_subtype
order by total_structures desc;