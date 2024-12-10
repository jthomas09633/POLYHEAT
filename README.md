# Automated Heat Capacity Analysis

A MATLAB package for the analysis of the thermodynamic properties of polymers measured using Differential/Fast Scanning Calorimetry. This method was developed with the intention of removing the human component in analysis revolving around the determination of steady state and transition regions. 


# How to Use

Download repository and extract file into desired folder. 

**Ensure you have the following toolboxes installed before running**

![Optimization Toolbox](https://www.mathworks.com/products/optimization.html)

![Parallel Computing Toolbox](https://www.mathworks.com/products/parallel-computing.html)

![Signal Processing Toolbox](https://www.mathworks.com/products/signal.html)

Launch MATLAB

Go to Home > Open > Project

Select the .prj file in the extracted folder

MATLAB will load the project and set it up automatically

Run main.m

Select the file or files you wish to analyze

Sit back, relax, grab a coffee, watch some cars go by, talk to co-worker, work on other things

Once the code is done analyzing open the variable dataStruct and your result will appear!

# Conventional Heating Segment
![Alt text](/Images/eyeTestExample.png)

Broadly, these regions can be identified by eye (often referred to as the "eye-test"), but the determination of the true start and end points is highly variable. To overcome this, an automated process built on fundamental polymer physics is required.  

# Key Features
The key features that are determined for any given heating segment are highlighted below. This package can perform the following analysis on batch samples imported regardless of instrument (tested on TA Instruments Q-Series DSC and Mettler Flash DSC-1) and for each heating segment contained in a given file.
- **Phase Identification and Isolation**
	- Identifying the quantity, type, and order of the phase changes measured (no event, glass transition, cold crystallization, and crystal melting). 
- **Steady State Baseline Determination**
	- Determines the regions associated with steady state behavior (solid, semi-solid/rubbery, and liquid state baselines)
- **Onset and Outset Determination**
	- Determining the entry and exit points of each phase change as deviations from steady state behavior
- **Transition Temperatures**
	- Measures the glass transition temperature and peak melting/crystallization temperatures. Glass Transition Temperature, $T_g$, is measured as the Fictive Temperature, $T_f$, using the Moynihan Method of Equal Areas. 
	
- **Quantification of Transition Energies**
	- For glass transitions, the heat capacity increment at $T_g$, $(\Delta c_p(T_g))$,  is reported as the separation between the extrapolated semi-solid/rubbery state and solid state baselines: 
	
		$\Delta c_p(T_g) = c_p^{rubbery}(T_g)-c_p^{solid}(T_g)$
	
	- For crystal melting the heat of fusion, $\Delta H$, is calculated using a sigmoidal like baseline underneath the melt peak to account for the partial melt contribution to the lifting of the baseline. This sigmoidal function accounts for the entry and exit slopes of the steady state baselines.

# Visualization of Output
The actual output is a data structure of the key parameters/properties for a given curve. Each row if of the data structure is a single imported file and separate fields are used for the entire file with a field dedicated to the analysis of each individual heating segment. 

Below is a visualization of a single heating segment (same one as the initial example above) and the key parameters and baselines calculated for the entire curve.

![Alt text](/Images/outputVisualized.png)
