# What are the 3 characteristics used to compare if NSI and local structure data match? 

Location, basement presence and number of stories.

# How much of the NSI data matches fully matches the local data? How much matches with 2 key characteristics? 

Only 36% of the NSI data matches fully matches the local data. 47% matches with 2 key characteristics (location and basement presence).

# What can cause discrepancy in mean structure value?

NSI misclassifies structures as one-story even though it is two story, thus NSI underestimates values for structures.

# Are discrepancies in financial losses higher for NSI-Local structure data when there is a location mismatch or when there is a property mismatch (and a location match)?  

Location mismatch causes a higher discrepancy in financial losses, as mentioned in the paper it says "dominate the overall discrepancy despite being a relatively uncommon form of inventory mismatch."

# Look at lines 279-292 – what are the implications for assessing building data quality and model performance? 

Some implications I think are that model performance can be affected if the NSI data is not accurate. Errors in the model are harder to determine whether its because of the NSI data or because of the model itself.

# Describe the methodologies used to correct the NSI data. What are advantages and disadvantages of this? Recall our discussion on parcels etc. at the beginning of the class. 

They linked NSI properties to Philadelphia's parcel polygons. They drop any NSI-only structures. They also adjusted for local characteristics (using local tract medians). And they also do structure value calibration. Some advantages of are that they drastically help reduce the total discrepancy percentage, reduces RMSE and misclassification. I cannot directly recall the discussion on parcels, but I think that a disadvantage is that if the parcel polygons are not accurate, then you can still have a mismatch in location.

# What are the policy implications of having the spatial distribution of flood risk wrong? 

Funding for certain communities would be affected if the spatial distribution of flood risk is wrong. Insurance companies would also be affected e.g some communites may pay too much for flood insurance or some may pay too little. Distribution of emergency resources would also be affected, e.g if an area is underfunded, then it may not be able to respond to a flood event as quickly as it should. Infrastructure investments would also be affected, e.g decisions that help reduce flood risk may not be made in the right areas if the spatial distribution of flood risk is wrong.