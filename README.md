
## rmisr

<!-- badges: start -->
<!-- badges: end -->

This package provides functions to download data from the [RMIS
api](https://github.com/PSMFC-Streamnet-RMPC/api-docs) . Data
documentation can be found here (what is the best link?) and users
should be familiar with data structure before attempting to download it.
Each function pulls data from a different RMIS table. An api key is
required for use and other function arguments will be passed to the api
as parameters. Reducing the size of data pulls by passing parameters to
your functions is strongly encouraged, and necessary in the case of
get_recovery(). The four functions are get_location(), get_release(),
get_recovery() and get_catchsample(). Each are covered below but have
common syntax.

This package uses the httr and jsonlite packages to do the api pull and
the dplyr package to bind json list output into a data frame in R.

The RMIS api uses pagination to control data pull size. These functions
get all data requested by 1) determining the total count of records
available in a query. 2) calculating the number of pages needed with
records per page set to 1000 (max allowed), and 3) applying an api pull
function to each needed page.

## Installation

``` r
 devtools::install_github("MattCallahan-NOAA/rmisr")
```

## Authentication

In order to use this package you will need to reach out to RMCP to get
an api key. Save the key in your working environment.

``` r
library(rmisr)
library(httr)
library(jsonlite)
library(dplyr)
library(magrittr)

token<-"your-api-key"
```

## Location

This function pulls location information. There are 39k+ location
records so downloading the whole dataset shouldn’t take more than a
minute.

``` r
## get type 2  locations reported by ADFG
adfg2<-get_location(token=token, reporting_agency="ADFG", location_type=2)
#> Downloading 2820 records
#> Time Elapsed: 2.76 secs

head(adfg2)
#>                                     id record_code format_version
#> 1 0021b051-e245-4bcc-aabb-9c660d0a1a05           L            4.2
#> 2 006ec3dc-4169-414a-a4c7-d2f9b817ba2c           L            4.2
#> 3 0076457e-372c-4042-8c5c-6d099e8bf472           L            4.2
#> 4 00b2b9b5-cf0c-465b-871a-999bb58e6133           L            4.2
#> 5 00b9b782-5ebd-45fa-b840-fbae16b78042           L            4.2
#> 6 00beb314-4153-4c39-a224-5795510ceeb5           L            4.2
#>   submission_date reporting_agency location_code location_type             name
#> 1        20230807             ADFG   1M2PW222 50             2 AK M 2 PW 222-50
#> 2        20230807             ADFG       1F116MB             2     AK F 1 16 MB
#> 3        20230807             ADFG   1F4PE282 11             2 AK F 4 PE 282-11
#> 4        20230807             ADFG   1F4CH272 70             2 AK F 4 CH 272-70
#> 5        20230807             ADFG   1F4KD262 85             2 AK F 4 KD 262-85
#> 6        20230807             ADFG   1F4PE282 60             2 AK F 4 PE 282-60
#>   latitude longitude psc_basin psc_region epa_reach
#> 1       NA        NA       PWS       CNAK        NA
#> 2       NA        NA      SEAK       SEAK        NA
#> 3       NA        NA      PENI       WEAK        NA
#> 4       NA        NA      CHIG       WEAK        NA
#> 5       NA        NA      KODI       WEAK        NA
#> 6       NA        NA      PENI       WEAK        NA
#>                                                              description
#> 1     Alaska marine, Region 2, Quadrant PW, District 222, Subdistrict 50
#> 2                            SF: Alaska freshwater, Region 1, HAINES, MB
#> 3 Alaska freshwater, Region 4, Quadrant PE, District 282, Subdistrict 11
#> 4 Alaska freshwater, Region 4, Quadrant CH, District 272, Subdistrict 70
#> 5 Alaska freshwater, Region 4, Quadrant KD, District 262, Subdistrict 85
#> 6 Alaska freshwater, Region 4, Quadrant PE, District 282, Subdistrict 60
```

## Release

Most functions require survey_definition_id, area_id, species_code,
start_year, and end_year as parameters. In order to correctly define
these parameters, first download several lookup tables. The full table
has ~180k records.

``` r
## get chinook releases for 1990 reported by ADFG
adfg1990_rel<-get_release(token=token, reporting_agency="ADFG", brood_year=1990)
#> Downloading 485 records
#> Time Elapsed: 0.71 secs

head(adfg1990_rel)
#>                                     id record_code format_version
#> 1 005e675f-a86c-45d2-8d7c-e7eda2cad98c           N            4.2
#> 2 00b8c0bc-922b-4531-87a4-00f6b43fdec8           T            4.2
#> 3 00c6a029-d3c6-466c-9366-e702caa454f0           N            4.2
#> 4 00f21444-9a2d-4500-8552-1a6334569793           T            4.2
#> 5 04432dbe-5bab-43cd-8ff0-bce358e6dc37           N            4.2
#> 6 049c0866-8a76-41c3-b2d5-8e0da8a9f13e           N            4.2
#>   submission_date reporting_agency release_agency coordinator
#> 1        20230802             ADFG           ADFG          12
#> 2        20230802             ADFG           KAKE          01
#> 3        20230802             ADFG           ADFG          12
#> 4        20230802             ADFG           ADFG          01
#> 5        20230802             ADFG            MIC          13
#> 6        20230802             ADFG           ADFG          12
#>   tag_code_or_release_id tag_type first_sequential_number
#> 1           !12912ADFG47     <NA>                      NA
#> 2             0401020508        3                      NA
#> 3           !12916ADFG02     <NA>                      NA
#> 4                 043822        0                      NA
#> 5           !13MIC910004     <NA>                      NA
#> 6           !12911ADFG07     <NA>                      NA
#>   last_sequential_number related_group_type related_group_id species  run
#> 1                     NA                 NA               NA       2 <NA>
#> 2                     NA                 NA               NA       5    2
#> 3                     NA                 NA               NA       6 <NA>
#> 4                     NA                 NA               NA       1    1
#> 5                     NA                 NA               NA       5    3
#> 6                     NA                 NA               NA       1    1
#>   brood_year release_location_code hatchery_location_code stock_location_code
#> 1       1990      1F4KD259 2410030            1F4KD252 31    1F4KD252 3110030
#> 2       1990           1M1NE109 42       1F1NE109 4210040    1F1NE109 4210040
#> 3       1990      1F4PE283 3410200            1F4PE283 34    1F4PE283 3410200
#> 4       1990      1F1SE106 4410310       1F1SE106 4410310    1F1SE106 4410310
#> 5       1990      1F1SE101 2510250       1F1SE101 2510250    1F1SE101 2510250
#> 6       1990   1F4KD259 1010035001       1F2UC247 5010060 1F2UC244 3010050024
#>   release_stage rearing_type study_type release_strategy avg_weight avg_length
#> 1             G            H          P               NA       1.24         NA
#> 2             G            H          P               NA       1.24         54
#> 3             F            H          P               NA       0.25         NA
#> 4             S            H          B               NA      11.25        100
#> 5             F            H          P               NA       0.70         NA
#> 6             S            H          P               NA      19.06         NA
#>   study_integrity cwt_1st_mark cwt_1st_mark_count cwt_2nd_mark
#> 1               N         <NA>                 NA           NA
#> 2               N         5000              26801           NA
#> 3               N         <NA>                 NA           NA
#> 4               N         5000              29667           NA
#> 5               N         <NA>                 NA           NA
#> 6               N         <NA>                 NA           NA
#>   cwt_2nd_mark_count non_cwt_1st_mark non_cwt_1st_mark_count non_cwt_2nd_mark
#> 1                 NA             0000                  19350             <NA>
#> 2                 NA             0000                1114538             5000
#> 3                 NA             0000                3500000             <NA>
#> 4                 NA             0000                 100490             5000
#> 5                 NA             0000                1499032             <NA>
#> 6                 NA             0000                  22257             <NA>
#>   non_cwt_2nd_mark_count counting_method tag_loss_rate tag_loss_days
#> 1                     NA            <NA>            NA            NA
#> 2                   2331               W         0.080             0
#> 3                     NA            <NA>            NA            NA
#> 4                   2029               P         0.064            21
#> 5                     NA               B            NA            NA
#> 6                     NA            <NA>            NA            NA
#>   tag_loss_sample_size tag_reused comments first_release_date_year
#> 1                   NA         NA     <NA>                    1991
#> 2                  603         NA     <NA>                    1991
#> 3                   NA         NA     <NA>                    1991
#> 4                  500         NA     <NA>                    1992
#> 5                   NA         NA     <NA>                    1991
#> 6                   NA         NA     <NA>                    1991
#>   first_release_date_month first_release_date_day last_release_date_year
#> 1                        7                     10                   1991
#> 2                        6                     15                   1991
#> 3                        6                     19                   1991
#> 4                        5                     15                   1992
#> 5                        5                      8                   1991
#> 6                        6                      5                   1991
#>   last_release_date_month last_release_date_day
#> 1                       7                    10
#> 2                       6                    15
#> 3                       6                    19
#> 4                       5                    15
#> 5                       5                     8
#> 6                       6                     5
```

## Recovery

The recovery table has over ten million records. I put a cap of 500k
records on this function but if you really want all of the data you can
loop it by run year.

``` r
## get chinook recovery for 1990 reported by ADFG of species 1
adfg1990_rec<-get_recovery(token=token, reporting_agency="ADFG", run_year=1990, species = 1)
#> Downloading 17648 records
#> Time Elapsed: 50.64 secs

head(adfg1990_rec)
#>                                     id record_code format_version
#> 1 00033e73-ca98-4a29-b63e-d93849c0186a           R            4.2
#> 2 00036f54-26b4-46ac-a93d-cc2b1cdf9caf           R            4.2
#> 3 00056099-6d99-4baf-ad81-0be886f2bdb9           R            4.2
#> 4 0007924d-a8da-446f-b681-e5ce86714d70           R            4.2
#> 5 00088a67-77af-40e6-b60a-17775e822e47           R            4.2
#> 6 000acd5b-84ed-45b7-8f13-91675c5b07c0           R            4.2
#>   submission_date reporting_agency sampling_agency recovery_id species run_year
#> 1        20230803             ADFG            ADFG      040074       1     1990
#> 2        20230803             ADFG            ADFG      076602       1     1990
#> 3        20230803             ADFG            ADFG      034038       1     1990
#> 4        20230803             ADFG            ADFG      027063       1     1990
#> 5        20230803             ADFG            ADFG      005017       1     1990
#> 6        20230803             ADFG            ADFG      075412       1     1990
#>   recovery_date_type period_type period fishery gear adclip_selective_fishery
#> 1                  R           7     07      10 11_5                        N
#> 2                  R           7     01      10 11_5                        N
#> 3                  R           7     05      10 11_5                        N
#> 4                  R           2     13      40 S1_N                        N
#> 5                  R           7     04      10 11_5                        N
#> 6                  R           7     02      10 11_5                        N
#>   estimation_level recovery_location_code sampling_site recorded_mark  sex
#> 1                3            1M1NE110 17            12          5009 <NA>
#> 2                3               1M1NE109            05          5009 <NA>
#> 3                3            1M1NE109 45            05          5009 <NA>
#> 4                4          1M1NE111 5004            04          5009 <NA>
#> 5                3               1M1SE101            06          5009 <NA>
#> 6                3            1M1NE110 31            12          5009 <NA>
#>   weight weight_code weight_type length length_code length_type
#> 1     NA          NA          NA    805           0           1
#> 2     NA          NA          NA    853           0           1
#> 3     NA          NA          NA    954           0           1
#> 4     NA          NA          NA    940           3           1
#> 5     NA          NA          NA    665           0           1
#> 6     NA          NA          NA    760           0           1
#>   detection_method tag_status tag_code tag_type sequential_number
#> 1                V          1   043107        9                NA
#> 2                V          1   073828        0                NA
#> 3                V          1   024222        0                NA
#> 4                V          1   042607        0                NA
#> 5                V          1   043108        9                NA
#> 6                V          1   036213        9                NA
#>   sequential_column_number sequential_row_number catch_sample_id sample_type
#> 1                       NA                    NA          274079           1
#> 2                       NA                    NA          274059           1
#> 3                       NA                    NA          274071           1
#> 4                       NA                    NA            <NA>           5
#> 5                       NA                    NA          274069           1
#> 6                       NA                    NA          274063           1
#>   sampled_maturity sampled_run sampled_length_range sampled_sex sampled_mark
#> 1                4          NA                   NA          NA           NA
#> 2                4          NA                   NA          NA           NA
#> 3                4          NA                   NA          NA           NA
#> 4                4          NA                   NA          NA           NA
#> 5                4          NA                   NA          NA           NA
#> 6                4          NA                   NA          NA           NA
#>   number_cwt_estimated
#> 1                 1.32
#> 2                 1.49
#> 3                 1.99
#> 4                 0.00
#> 5                 1.92
#> 6                 1.34
```

## Catchsample

The get_catchsample() function pulls data from the catchsample table.
This table has about 480k records, results should definitely be filtered
if at all possible.

``` r
## get chinook catch samples for 1990 reported by ADFG of species 1
adfg1990_c<-get_catchsample(token=token, reporting_agency="ADFG", catch_year=1990, species = 1)
#> Downloading 684 records
#> Time Elapsed: 2.14 secs

head(adfg1990_c)
#>                                     id record_code format_version
#> 1 008161ba-bb0a-4c58-b968-08aa55827271           S            4.2
#> 2 0104b5fa-a9a3-4c9b-9cec-44256f737a76           S            4.2
#> 3 01213afa-c9a0-434b-88ad-267bfe9a2439           S            4.2
#> 4 0124c5a6-48ef-43ae-981d-7d6069215e81           S            4.2
#> 5 01580761-ac0f-4ce4-b0c8-d19e52161532           S            4.2
#> 6 01793fdd-e399-4a72-a480-9809639de5d6           S            4.2
#>   submission_date reporting_agency sampling_agency catch_sample_id species
#> 1        20230803             ADFG            ADFG          274066       1
#> 2        20230803             ADFG            ADFG          273764       1
#> 3        20230803             ADFG            ADFG          273976       1
#> 4        20230803             ADFG            ADFG          274027       1
#> 5        20230803             ADFG            ADFG          274105       1
#> 6        20230803             ADFG            ADFG          274078       1
#>   catch_year period_type period first_period last_period fishery
#> 1       1990           7     02           23          24      10
#> 2       1990           7     35         <NA>        <NA>      25
#> 3       1990           7     28         <NA>        <NA>      28
#> 4       1990           7     32         <NA>        <NA>      28
#> 5       1990           7     04           32          33      25
#> 6       1990           7     06           34          39      10
#>   adclip_selective_fishery estimation_level detection_method sample_type
#> 1                        N                3                V           1
#> 2                        N                4                V           1
#> 3                        N                4                V           1
#> 4                        N                4                V           1
#> 5                        N                4                V           1
#> 6                        N                3                V           1
#>   sampled_maturity sampled_run sampled_length_range sampled_sex sampled_mark
#> 1                4          NA                   NA          NA           NA
#> 2                4          NA                   NA          NA           NA
#> 3                4          NA                   NA          NA           NA
#> 4                4          NA                   NA          NA           NA
#> 5                2          NA                   NA          NA           NA
#> 6                4          NA                   NA          NA           NA
#>   number_caught escapement_estimation_method number_sampled
#> 1          1021                           NA            213
#> 2            65                           NA              0
#> 3           123                           NA              0
#> 4            16                           NA              0
#> 5            72                           NA              0
#> 6           289                           NA            101
#>   number_cwt_estimated number_recovered_decoded number_recovered_no_cwts
#> 1                 4.79                       11                        4
#> 2                   NA                        0                        0
#> 3                   NA                        0                        0
#> 4                   NA                        0                        0
#> 5                   NA                        0                        0
#> 6                 2.86                        5                        0
#>   number_recovered_lost_cwts number_recovered_unreadable
#> 1                          0                           0
#> 2                          0                           0
#> 3                          0                           0
#> 4                          0                           0
#> 5                          0                           0
#> 6                          0                           0
#>   number_recovered_unresolved number_recovered_not_processed
#> 1                           0                              0
#> 2                           0                              0
#> 3                           0                              0
#> 4                           0                              0
#> 5                           0                              0
#> 6                           0                              0
#>   number_recovered_pseudotags mr_1st_partition_size mr_1st_sample_size
#> 1                          NA                   213                213
#> 2                          NA                     0                  0
#> 3                          NA                     0                  0
#> 4                          NA                     0                  0
#> 5                          NA                     0                  0
#> 6                          NA                   101                101
#>   mr_1st_sample_known_ad_status mr_1st_sample_obs_adclips mr_2nd_partition_size
#> 1                           213                        15                    NA
#> 2                            NA                        NA                    NA
#> 3                            NA                        NA                    NA
#> 4                            NA                        NA                    NA
#> 5                            NA                        NA                    NA
#> 6                           101                         5                    NA
#>   mr_2nd_sample_size mr_2nd_sample_known_ad_status mr_2nd_sample_obs_adclips
#> 1                 NA                            NA                        NA
#> 2                 NA                            NA                        NA
#> 3                 NA                            NA                        NA
#> 4                 NA                            NA                        NA
#> 5                 NA                            NA                        NA
#> 6                 NA                            NA                        NA
#>   mark_rate awareness_factor sport_mark_incidence_sampl_size
#> 1    0.0704               NA                              NA
#> 2        NA               NA                              NA
#> 3        NA               NA                              NA
#> 4        NA               NA                              NA
#> 5        NA               NA                              NA
#> 6    0.0495               NA                              NA
```
