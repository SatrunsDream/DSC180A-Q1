create or replace table `capstone2025.CA_PropertyStats_ByLandCover` as
select 
  lc.fips,
  lc.land_cover_subtype,
  nsi.st_damcat,
  nsi.bldgtype,
  count(*) as structure_count,
  count(distinct lc.h3_cell) as h3_cell_count,
  avg(nsi.cc) as avg_content_cost
from `capstone2025.CA_CountyLandCover_H3` lc
join `capstone2025.NSI` nsi
  on lc.h3_cell = nsi.h3  
  and cast(lc.fips as int64) = nsi.fips 
group by fips, land_cover_subtype, st_damcat, bldgtype;