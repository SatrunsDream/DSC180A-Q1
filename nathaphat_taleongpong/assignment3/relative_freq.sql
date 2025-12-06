drop table `capstone-477405.Capstone2025.NSI_LandUse_Stats`;
create table `capstone-477405.Capstone2025.NSI_LandUse_Stats` as
with grouped_data as (
  select
    county_fips,
    land_use_class,
    st_damcat,
    bldgtype,
    num_story,
    sqft,
    val_struct,
    sum(cc) as total_cc
  from
    `capstone-477405.Capstone2025.NSI_LandUse`
  group by
    county_fips, land_use_class, st_damcat, bldgtype, num_story, sqft, val_struct
),

county_totals as (
  select
    county_fips,
    land_use_class,
    sum(total_cc) as county_land_use_total
  from grouped_data
  group by county_fips, land_use_class
)

select
  a.*,
  ct.county_land_use_total,
  a.total_cc / ct.county_land_use_total as relative_freq
from grouped_data a
join county_totals ct
on a.county_fips = ct.county_fips and a.land_use_class = ct.land_use_class
order by county_fips, land_use_class, total_cc desc;