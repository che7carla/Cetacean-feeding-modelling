%% A two-sided two-sample t-test with Bonferroni correction
% Used to investigate the presence of statistically significant differences 
% between the two classes of target behaviours, Feeding and Other, in relation to 
% the values of each of the 20 environmental features.
clc
clear all

% Add path and directory
addpath(genpath("..\..\lib\config\"));
load_path_CFMs();

% Run the analysis for the dataset dt_g
perform_ttest2('dt_g.xlsx', 'T-test_results_g.xlsx', 'Significant_results_g.xlsx');

% Run the analysis for the dataset dt_s
perform_ttest2('dt_s.xlsx', 'T-test_results_s.xlsx', 'Significant_results_s.xlsx');

% Run the analysis for another dataset dt_x
perform_ttest2('dt_t.xlsx', 'T-test_results_t.xlsx', 'Significant_results_t.xlsx');
