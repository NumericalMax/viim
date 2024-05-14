# viim

Visual impairment (viim) is a widespread condition that affects individuals across all ages, nations, and backgrounds. Digital and mobile technology might pose a potential solution to address the challenge of health-coverage, specifically in underserved areas. This repository contains two main components:

1. **Application Source Code**: This component includes the complete source code for an iOS application that conducts the logMAR eye test, primarily designed for use on the iPhone 13 Pro. The application features a comprehensive questionnaire and employs facial landmark tracking to monitor the user's expressions during the test.
2. **Data Analysis Script**: This script is designed to process and analyze data exported after each eye test. It aims to explore potential correlations between facial expressions and the ability to read test letters, which may indicate visual impairment. The analysis utilizes visualization tools, classical statistical methods, and explainable machine learning techniques.

## Installation and Build

1. iOS application: Move to `src/` and run `xcodegen generate`
2. Analysis: run `pip install -r evaluation/requirements.txt` in a Python environment of your choice.

## Run

1. run the iOS application and perform the eye test according to the instructions in the application. After each run, export the JSON file and transfer it to the computer containing the analysis script and place it in the `evaluation/data/` folder.
2. to replicate the data analysis as performed in our work, first run the script `evaluation/src/main.py` to load the raw data and transform it into a tabular structure. Secondly, run `evaluation/src/feature_engineering.py` to preprocess and extract relevant features for further analysis. Finally, open the Jupyter notebook `evaluation/notebooks/analysis.ipyb` and analyze the data stored in `evaluation/data/` step by step.

Note that the paths are relative and must be executed from the correct location, which is normally the same as the folder in which the script is located.

## Acknowledgement

As the commit history must be hidden, this repository does not contain any information about the authors of the source code. The authors include [Julian Ostarek](https://github.com/jlnstrk), [Efe Berk Ergüleç](https://github.com/efeerg), [Florian Schweizer](https://github.com/chFlorian), [Elena Mille](https://github.com/elmille) and [Maximilian Kapsecker](https://github.com/NumericalMax).

## Cite

If you use this software in your (research) project, please cite the following article: TBD
