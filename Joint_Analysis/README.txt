Quantification of Joint Distance and Congruency for the Talcrural Joints
Revised for MATLAB R2020a on 11/05/20

This set of 9 main scripts is broken down into groups of 3, one group for each individual joint (tibiotalar (TT), talofibular (TaF), tibiofibular(TiF)).
For each joint, the three main scripts needed are Distance_Corrospondence_'joint'_Github.m, SSM_Congruency_'joint'_Github.m, Common_Corrospondence_'joint'_Github.m.
The data provided are surfaces files for all the bones, nodal, curvature and curvature data, as well as a set of functions needed for the main scripts.
The first two scripts will produce .xlsx files which are used in subsequent scripts, and the final script produces figures of the joint measurements and 
further calculations can be performed off of the outputted variables.

For example, if calculations of the tibiotalar joint were desired, the appropriate work flow would be:
1. Download all contained files
2. Run Distance_Corrospondence_TT_Github.m and keep Nodal_Data_TT_Github.xlsx in the same pathway.
3. Run SSM_Congruency_TT_Github.m and keep Curvature_Data_TT_Github.xlsx in the same pathway.
4. Run Common_Corrospondence_TT_Github.m and use MeanDist_95 and MeanRMS_95 for further calculations.