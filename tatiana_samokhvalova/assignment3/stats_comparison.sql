with county_lc_stats as (
  select fips, land_cover_subtype, bldgtype, sum(cc) as counts
  from `capstonew4.Capstone2025.nsi_landcover`
  group by fips, land_cover_subtype, bldgtype
),
neighbor_stats as (
  select
    county.fips as county,
    neighbor.fips as neighbor,
    county.land_cover_subtype,
    county.bldgtype,
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
    county,
    land_cover_subtype,
    bldgtype,
    abs(avg(county_stat - neighbor_stat)) as delta
  from neighbor_stats
  group by county, land_cover_subtype, bldgtype
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
order by delta desc