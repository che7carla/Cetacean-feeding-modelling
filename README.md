﻿# Cetacean-Feeding-Modelling
 
## Table of Contents:
- [Description](#description)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Setup](#setup)
- [Usage](#usage)
- [Contact](#contact)
- [License](#license)

## Description [[to ToC]](#table-of-contents)

Cetacean Feeding Modelling (CFMs) is a Machine Learning-based framework developed to predict cetacean feeding activity in relation to environmental variables in the Central-eastern Mediterranean Sea. CFMs combine behavioral data ('Feeding' vs 'Other' behaviors) with 20 environmental predictors derived from sources such as Copernicus Marine Service (CMS) and EMODnet-bathymetry. By integrating Random Forest and RUSBoost classifier algorithms, the CFMs capture species-specific feeding patterns for three target cetacean species - striped dolphin, common bottlenose dolphin, and Risso's dolphin - in the Gulf of Taranto, our study area, providing a tool for marine conservation and management through predictive feeding maps and offering insights to improve knowledge on feeding habitat characteristics.


## Project Structure [[to ToC]](#table-of-contents)

The project structure is organized as follows:

- `data` folder contains two subfolders:
  - `raw` folder contains two subfolders with the raw dataset:
	- `Dataset`: contains the Excel file of the raw dataset used to generate the subset used to build the models.
	- `Extrapolation`: contains the Excel file used to predict feeding habitats of Risso's dolphin for all the Gulf of Taranto, using the bio-chemical model.
		
  - `processed` folder contains three subfolders, one for each cetacean species studied:
	- `Dataset_grampus`: contains five Excel files with the processed datasets related to the Risso's dolphin species, used to run five model with a different variables characterization.
	- `Dataset_stenella`: contains five Excel files with the processed datasets related to the striped dolphin species,used to run five model with a different variables characterization.
	- `Dataset_tursiops`: contains five Excel files with the processed datasets related to the common bottlenose dolphin species,used to run five model with a different variables characterization.
		
- `src` folder contains the source code files and subfolders:
  - `lib` folder contains libraries for statistical analysis, pre-processing machine learning, and utility functions.
  - `models` folder contains the main script for running the ML models.
  - `t-test` folder contains the main script for running the t-test analysis.
  - `extrapolation` folder contains the main script for running the best ML models for a target species predicting on a new area.




## Requirements [[to ToC]](#table-of-contents)
- MATLAB Version 9.14 (R2023a) (https://it.mathworks.com/products/matlab.html)
- Statistics and Machine Learning Toolbox Version 12.5 (R2023a) (https://it.mathworks.com/products/statistics.html)
- Parallel Computing Toolbox Version 7.8 (R2023a) (https://it.mathworks.com/products/parallel-computing.html)

## Setup [[to ToC]](#table-of-contents)
To set up the project, follow these steps:

1. Clone the repository: 
    ```
	git clone https://github.com/che7carla/Cetacean-feeding-modelling.git
    ```
2. Navigate to the project directory:
    ```
    cd Cetacean-feeding-modelling
    ```

## Usage [[to ToC]](#table-of-contents)
To run the experiment follow these steps:

1. Run the script to train machine learning models:
````
 \src\models\main_models.m
````
2. Run the script to do the t-test analysis of the environmental variables for Feeding vs Other behaviors:
````
\src\t-test\ttest.m
````

3. Run the script to predict the Risso's dolphin feeding habitats for all the Gulf of Taranto using the M_bio model already trained, on the three summer months of 2024:
````
\src\extrapolation\Extrapolation_Gulf_of_Taranto.m
````


## Contact [[to ToC]](#table-of-contents)

For any questions or inquiries, please contact [Carla Cherubini](mailto:c.cherubini@phd.poliba.it) or [Rosalia Maglietta](mailto:rosalia.maglietta@cnr.it)

## Cite this

Cherubini, C., Cipriano, G., Saccotelli, L., Dimauro, G., Coppini, G., Carlucci, R., Fanizza, C. and Maglietta, R., 2025. Cetacean feeding modelling using machine learning: A case study of the Central-Eastern Mediterranean Sea. Ecological Informatics, p.103066.


## License [[to ToC]](#table-of-contents)

This project is licensed under the [Apache License 2.0](LICENSE).
