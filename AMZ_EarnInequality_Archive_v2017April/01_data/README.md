
# Construction of the Worker Eligible and Immigrant Candidate Files

Date: 2016-02-05

Author: Kevin McKinney

## INPUT FILES:
   - Census Numident (2012)     - 469,900,000 PIK observations
   - UI and OPM Snapshot (2013) - 269,200,000 PIK observations
     - UI data begins in 1990:1 and ends in 2014:3 (start dates vary by state)
     - OPM data begins in 2000:1 and ends in 2013:4

   - These programs use the Census Numident located at:
   - These programs use the pikNN_analysis_datasets located at:
   - The analysis datasets were built from the snap_user data at:

## OUTPUT FILES:
   - Worker Eligible
   - Immigrant Candidate

## OVERVIEW
The Census Numident is used to create the population of all persons eligible to work in the United States.
Using the UI and OPM data we can determine a portion of the eligible persons actively working for firms
covered by state UI and the federal government.  Combined, the earnings data cover private firms, state/local
government, federal workers, and some self-employment (if the firm is incorporated and the proprietor
draws a salary). The starting and ending date of the data varies by state/federal government.  By 2003:3
all states and the federal government are participating in LEHD and we have virtually complete coverage
of the working population (excluding a large portion of self employment).

The UI data contains employee earnings reported by covered firms.  Not all reported earnings match with
the Census Numident and some of the earnings that do match appear to be due to multiple workers sharing
the same SSN.  There are also earnings reports for otherwise elgible workers for time periods where the
person is out of the eligible age range, not yet emigrated to the USA, or reported dead.  These
earnings records are placed in the immigrant candidate file.  The earnings records in the immigrant
candidate file represent real economic activity, but we cannot reliably associate this activity with a
specific known person.  For some purposes it is useful/reasonable to combine the worker eligible and immgirant
candidate files, but for other analyses it is better to use only the worker eligible file.

## PROGRAM SEQUENCE
 - 01.01.merge_cnum_ui.sas - Reads in both the Census Numident and the UI/OPM data.  Sorts each file by PIK
   to create a unique list of PIK's from each source.  The two sources are then merged to create a dataset
   of all the unique PIK's and their source(s).

   - INPUTS:
      cnum_2012
      stacked pik00_analysis_dataset - pik99_analysis_dataset
   - OUTPUTS:
      cnum_pik (unique PIK's on the Numident)
      merge_cnum_ui (PIK's on both the Numident, UI, and OPM)

 - 02.01.num_clean.sas - Clean up variables on the Census Numident.  
        dob - date of birth
        dod - date of death
        doc - oldest cycle date (first appearance on Numident)
        gender - sex
        pob - place of birth
        pcf_race - race/ethnicity

   - INPUTS:
      cnum_pik
   - OUTPUTS:
      cnum_strip2 (469,900,000 obs)

 - 03.01.cnum_yob.sas - Uses information on the Numident to devlop an imputation model for DOB year.
   The conditioning variables are DOC_year, gender, and POB.  A large table is created that can be used to
   form the appropriate marginal distribution conditional on the available DOC_year, gender, and POB.

   Uses only the observations where DOB_year is not missing.

   - INPUTS:
      cnum_strip(where=(DOB_year~=.))
   - OUTPUTS:
      DOB_imp_table (1,708,000 obs)

 - 03.02.cnum_yob2.sas - Checks to make sure that the patterns present for DOC_year*gender*POB for the records where
   DOB year is missing are also present in the data where DOB year is not missing.  To improve the performance of the
   impute, I drop combinations of the conditioning variables that are NOT in the missing data.

   - INPUTS:
      cnum_strip(where=(DOB_year=.)) (2,726,000 obs)
   - OUTPUTS:
      DOB_imp_table2 (455,800 obs)

 - 03.03.cnum_yob3.sas - Create the CDF within each DOC_year*gender*POB cell. This operation places DOB in columns.

   - INPUTS:
      DOB_imp_table2
   - OUTPUTS:
      DOB_imp_table3 (2,000 observations)


 - 03.04.cnum_yob4.sas - Impute DOB year and conditional on the year impute the month and the day. Update the Numident
   strip with the imputed DOB values.

   - INPUTS:
      cnum_strip(where=(DOB_year~=.))
      DOB_imp_table3
   - OUTPUTS:
      cnum_strip2 (469,900,000 obs)

 - 04.01.cnum_gender_POB.sas - Randomly assign gender and POB for the small number of records with missing values.  We
   didn't do this earlier in order to retain missing status as a predictor. Gender is imputed for 22,280,000 observations,
   but most of the missing gender values occur prior to 1920.  There are only 68,400 imputed values for POB. PIKs that never
   appear on the Numident have no available demographic characteristics.

   eligible status is determined by the following:
      1. PIK must appear on the Numident
      2. 18<= age <=70
      3. years in the US is greater than or equal to zero
      4. Date of Death is after the beginning of the current year

   The first condition is not time varying, but the last three depend on the year.

   The year_first and year_last variables show the years between 1990 and 2013 that the person is eligible to work
   given all of the available information on the Numident. The eligible variable is equal to one if a PIK is ever
   eligible during the period 1990 to 2013 and is zero otherwise.  About 150 million workers on the Numident are
   never eligible to work during 1990-2013.

   - INPUTS:
      cnum_strip2 (467,000,000 obs)
   - OUTPUTS:
      cnum_strip3 (482,000,000 obs)

 - 05.01.get_ui.sas - Get the UI data for all years.  Retain only the dominant records and use the contribution variable
   to create a PIK YEAR dataset of annual earnings.

   - VARIABLES: pik year state num_jobs contribution real_ann_earn

   - INPUTS:
      stacked pik00_analysis_dataset - pik99_analysis_dataset (dominant records only)
   - OUTPUTS:
      uipikyear (2,856,000,000 obs)

- 05.02.analysis_records.sas -  Using the information about work eligibility on the cnum_strip3 file and the UI earnings records,
   separate the records into the worker eligible and immigrant candidate files.  Persons that appear on the Numident, but are
   never eligible are immediately discarded. Eligible persons only on the Numident are added back in at a later stage.  Records only
   on the UI go to the immigrant candidate file.  Records that are on both go to the worker eligible file unless the number of jobs
   in the year is greater than 12. Next we add records for years a worker is eligible but not working.  Earnings records that are
   out of the age range are sent to the immigrant candidate file.

   - INPUTS:
      cnum_strip3(where=(not(source=1)) (269,000,000 PIK obs)
      uipikyear (2,856,000,000 PIK YEAR obs)
   - OUTPUTS:
      worker_eligible (5,144,000,000 obs)
      immig_cand (193,700,000 obs)
