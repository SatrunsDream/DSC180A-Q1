-- drop table `capstone-477405.Capstone2025.NSI_LandCover`;
create table `capstone-477405.Capstone2025.NSI_LandCover` as
select
  nsi.*,
  lc.county_fips,
  lc.land_cover_id,
  lc.land_cover_type
from
  `capstone-477405.Capstone2025.assignment4` nsi
join
  `capstone-477405.Capstone2025.CALandCoverH3` lc
on
  nsi.h3 = lc.h3_cell_id;