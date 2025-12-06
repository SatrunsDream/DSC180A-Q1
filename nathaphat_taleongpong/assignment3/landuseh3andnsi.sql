-- drop table `capstone-477405.Capstone2025.NSI_LandUse`;
create table `capstone-477405.Capstone2025.NSI_LandUse` as
select
  nsi.*,
  lu.county_fips,
  lu.land_use_id,
  lu.land_use_class
from
  `capstone-477405.Capstone2025.assignment4` nsi
join
  `capstone-477405.Capstone2025.CALandUseH3` lu
on
  nsi.h3 = lu.h3_cell_id;