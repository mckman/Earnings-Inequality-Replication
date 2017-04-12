
Subject: Reproduction Archive for:
         "Earnings Inequality and Mobility Trends in the United States:
          Nationally Represenatative Estimates from Longitudinally Linked
          Employer Employee Data"
Authors: Kevin McKinney (John Abowd and Nellie Zhao)
Date: April 10, 2017


HC estimates
----------------------------

Input files:
   Vintage: s2013_2015_07_30
   EHF, ECF, ICF

   Snapshot s2013 includes data through at least 2014:3 for all states
   except for Kansas (2013:4) and OPM (2013:4)
   This allows for a 1 quarter window around the last complete year.

Programs:
  Location: akm_s2013

  Subdir: 01_data_setup
  Notes: Programs to create the HC estimates input files
         Earnings inequality estimates also use these files. 
         See README_akm_data_setup.txt for more details

  
  Subdir: 04_runcg64_alljobs_2004_2013
  Notes: Programs to create the HC estimates
         See README_runcg.txt for more information

Output Files:
  Earnings Data (HC estimates input files):
  HC estimates:

Inequality Estimates
----------------------------

LEHD Earnings Data
   Location: 01_data
   Notes: See READ_ME.txt file for more information.

LEHD Earnings Distributions
   Location: 02_earn_dist
   Notes: Earnings distributions by regime
          Parametric measures are also based off these results

Employment to Population Ratio
   Location: 03_ep_ratio
   Notes:

UI and ACS/CPS Earnings Distribution Comparison
   Location: 04_cps_acs
   Notes:

Earnings Mobility by Firm Type
   Location: 05_earn_mobility
   Notes:

Earnings and Flow Decomposition
   Location: 06_earn_decomp
   Notes:
