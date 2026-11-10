Optimized Binary Distillation Column Simulation ⚗️📊
This repository contains a dynamic MATLAB simulation of a binary distillation column (Benzene-Toluene) utilizing the McCabe-Thiele graphical method. Unlike static plotting scripts, this project acts as an automated process engineering tool. It dynamically calculates thermodynamic limits to achieve a user-defined separation efficiency, models the physical plant requirements, and exports structured datasets for downstream analytics.

📈 Simulation Output🚀 FeaturesDynamic Thermodynamic Optimization: Automatically calculates the pinch point and Minimum Reflux Ratio ($R_{min}$) required to hit a strict 95% separation target.

Industrial Plant Heuristics: Applies standard engineering multipliers ($1.5 \times R_{min}$) and a 75% tray efficiency factor to bridge theoretical thermodynamics with actual physical plant design. 
Algorithmic Stage Construction: Uses a continuous mass-balance intersection algorithm (stepwise construction) to find the exact number of physical trays and locate the optimal feed tray.

Data Analytics Ready: Automatically formats and exports a stage-by-stage composition dataset to CSV (Distillation_Stage_Compositions.csv). 
Trays are dynamically tagged by operational section (Condenser, Rectifying, Stripping) for direct integration with SQL or Power BI.💻 

Tech StackLanguage: MATLAB 
Concepts: Chemical Process Engineering, Thermodynamics, Process Optimization, Data Structuring
