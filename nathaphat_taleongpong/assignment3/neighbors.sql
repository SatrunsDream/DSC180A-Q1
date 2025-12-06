-- delete table `capstone-477405.Capstone2025.CACounties`;
create table `capstone-477405.Capstone2025.CACounties` as
select
  county_fips_code AS county_fips,
  county_name,
  county_geom
from
  `bigquery-public-data.geo_us_boundaries.counties`
where
  state_fips_code = '06';

-- delete table `capstone-477405.Capstone2025.CACountyNeighbors`;
create table `capstone-477405.Capstone2025.CACountyNeighbors` as
with ca_counties as (
  select
    county_fips,
    county_name,
    county_geom
  from
    `capstone-477405.Capstone2025.CACounties`
),

county_neighbors as (
  select distinct
    c1.county_fips AS county_fips,
    c2.county_fips AS neighbor_fips
  from
    ca_counties c1
  join
    ca_counties c2
  on
    ST_Touches(c1.county_geom, c2.county_geom)
  where
    c1.county_fips != c2.county_fips
)

select
  county_fips,
  array_agg(distinct neighbor_fips order by neighbor_fips) as neighboring_counties,
  count(distinct neighbor_fips) as num_neighbors
from
  county_neighbors
group by
  county_fips
order by
  county_fips;