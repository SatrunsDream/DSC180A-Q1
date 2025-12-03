# step 3
create or replace table `capstonew4.Capstone2025.nsi_landcover` as

select nsi.*, lc.land_cover_subtype from `capstonew4.Capstone2025.NSI_Data` nsi
join `capstonew4.Capstone2025.county_landcover_h3` lc on lc.h3_lvl9 = nsi.h3