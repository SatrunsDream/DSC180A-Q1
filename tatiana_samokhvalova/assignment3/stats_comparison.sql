with county_lc_stats as (
  select fips, st_damcat, bldgtype, num_story, sqft, val_struct, land_cover_subtype, sum(cc) as counts
  from `capstonew4.Capstone2025.nsi_landcover`
  group by fips, st_damcat, bldgtype, num_story, sqft, val_struct, land_cover_subtype
),
neighbor_stats as (
  select
    county.fips as county,
    neighbor.fips as neighbor,
    county.st_damcat,
    county.bldgtype,
    county.num_story,
    county.sqft,
    county.val_struct,
    county.land_cover_subtype,
    county.counts as county_stat,
    neighbor.counts as neighbor_stat
  from county_lc_stats county
  join `capstonew4.Capstone2025.county_neighbors` neighbor_table on county.fips = neighbor_table.county
  join county_lc_stats neighbor
    on neighbor.fips = neighbor_table.neighbor
    and neighbor.land_cover_subtype = county.land_cover_subtype
    and neighbor.bldgtype = county.bldgtype
),
deltas as (
  select
    county, st_damcat, bldgtype, num_story, sqft, val_struct, land_cover_subtype,
    avg(county_stat - neighbor_stat) as delta,
    avg(abs(county_stat - neighbor_stat)) as delta_abs
  from neighbor_stats
  group by county, st_damcat, bldgtype, num_story, sqft, val_struct, land_cover_subtype
),

-- for viz
counties as (
  select cast(county_fips_code as int64) as fips, county_geom as geom
  from `bigquery-public-data.geo_us_boundaries.counties`
  where cast(county_fips_code as int64) in (select distinct fips from `capstonew4.Capstone2025.NSI_Data`)
)

select d.*, c.geom
from deltas d
join counties c on d.county = c.fips
-- example filter
where st_damcat = 'IND' and bldgtype = 'H'
order by delta desc