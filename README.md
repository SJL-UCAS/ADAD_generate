ADIA-CMGR:
This repository contains codes for generating the 500 m Agricultural Drought Impacted Area Dataset in China’s main grain region (CMGR). The dataset can be downloaded at: https://zenodo.org/records/17940187.

There provides an example of the evaluation and extraction of the agricultural drought impacted areas in Hunan Province. The agricultural drought impacted area of other provinces are extracted by the same code.

LAI_download:
This script is used to download and preprocess the MODIS LAI data

Evaluation_of_different_thresholds.m :
This code is used to evaluate the accuracy between the historical agricultural drought impacted areas and the simulated areas extracted by different thresholds in different phenological periods. The optimal thresholds were determined by R an RMSE.

Agricultural_drought_area_extraction :
This code is used to extract the agricultural drought impacted areas by the determined optimal thresholds in key phenological periods.

