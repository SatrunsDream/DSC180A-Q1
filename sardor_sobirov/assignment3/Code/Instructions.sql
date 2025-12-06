Hi team,
 
I didn’t finish aggregating some NSI data into cells for you to work with on your next assignment, but I know you like getting a head start during the weekend.
 
So, here is a brief overview of the assignment and you can get the preparatory stages done:
 
#
# Capstone 2025 Data Team
# Cell statistics assignment (assignment 3).
#
# Using NSI data aggregated by cell, as well as overture structures/land use/land cover, obtain
# classes by county/use/cover and obtain statistics on NSI property characteristics.  Rank these
# to identify outliers in property characteristic statistics between counties and neighbors.
#
 
#
# Steps:
# Obtain property characteristics .csv file and import to BQ table.
# Obtain neighbor counties for each county in area of interest.
# Generate land cover regions within each county.
# Obtain H3 cells by land cover region in each county.
# Obtain property value statistics by county/land cover grouping by land use.
# Obtain differences in property value statistics for each county/land cover/land use vs. neighbor counties.
# Rank results by these deltas.
# Obtain visualizations of steps that support any conclusions you may derive.
#
 
The area of interest will be the state of California.  What you can do to start is:
Using the county layer, obtain the set of CA counties and for each, get the pairs of spatially adjoining counties.
Join each county with the land cover table in the overture data, to obtain land cover polygons within each county (st_intersection).
For each of these land cover polygons, obtain the set of H3 cell IDs at level 8 that intersect the polygon (hint: there is a ‘polyfill’ function).
 
I will provide cell statistics later, but these first steps should give you a good head start.  Have a great weekend!
 
Pete