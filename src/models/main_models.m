clear all
close all
clc
%%
% %% Add path and directory
%addpath(genpath("..\..\lib\config\"));

%% Datasets generation
% Process the original dataset for each dolphin species, generating the dataset needed 
process_dolphin_data('dataset.xlsx', 'dt');

%% Read dataset
% Define a variable for selecting which dataset to use.
%Options can be: 'g', 'g_bio', 'g_fisic', 'g_fisio', 'g_ino', 's', 's_bio', 's_fisic', 
 %'s_fisio', 's_ino', 't', 't_bio', 't_fisic', 't_fisio', 't_ino'

datasetType = 'g'; % Change this value to the desired dataset type.

% Use a switch statement to load the correct file based on the datasetType.
switch datasetType
    case 'g'
        dataset = 'dt_g.xlsx';
    case 'g_bio'
        dataset = 'dt_g_bio.xlsx';
    case 'g_fisic'
        dataset = 'dt_g_fisic.xlsx';
    case 'g_fisio'
        dataset = 'dt_g_fisio.xlsx';
    case 'g_ino'
        dataset = 'dt_g_ino.xlsx';
    case 's'
        dataset = 'dt_s.xlsx';
    case 's_bio'
        dataset = 'dt_s_bio.xlsx';
    case 's_fisic'
        dataset = 'dt_s_fisic.xlsx';
    case 's_fisio'
        dataset = 'dt_s_fisio.xlsx';
    case 's_ino'
        dataset = 'dt_s_ino.xlsx';
    case 't'
        dataset = 'dt_t.xlsx';
    case 't_bio'
        dataset = 'dt_t_bio.xlsx';
    case 't_fisic'
        dataset = 'dt_t_fisic.xlsx';
    case 't_fisio'
        dataset = 'dt_t_fisio.xlsx';
    case 't_ino'
        dataset = 'dt_t_ino.xlsx';
    otherwise
        error('Invalid dataset type. Please check your selection.');
end

% Load the selected dataset
dataset = readtable(dataset);

% Display the first few rows of the dataset to confirm it loaded correctly
disp("Loaded dataset:");

%% Splitting original dataset into training and test dataset
test_dataset_size = 0.20; 
[training_dataset, test_dataset] = create_training_test_dataset(dataset, test_dataset_size);
writetable(training_dataset, "training_dataset.xlsx", 'WriteRowNames',true);
writetable(test_dataset, "test_dataset.xlsx", 'WriteRowNames',true);

%% Create table for k-fold cross validation results
algorithm_names = {'RUSboost', 'RandomForest'};
results_training = table('Size', [2, 4], ...
    'VariableTypes', {'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'Accuracy', 'Specificity', 'Sensitivity', 'BCR'},...
    'RowNames', algorithm_names);

results_test = table('Size', [2, 4], ...
    'VariableTypes', {'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'Accuracy', 'Specificity', 'Sensitivity', 'BCR'},...
    'RowNames', algorithm_names);

result_experiment = struct();
target_feature_name = 'Behaviour';
max_objective_evaluations = 100;
k = 5;

%% Training RUSboost model
fprintf("\n===================================================================\n");
fprintf("Training model using RUSboost with k=%d\n", k);
fprintf("===================================================================\n");

result_experiment.RUSboost = RUSboost_function(training_dataset, target_feature_name, max_objective_evaluations, k);

results_training("RUSboost", "Accuracy") = {result_experiment.RUSboost.validation_results.validation_accuracy};
results_training("RUSboost", "Sensitivity") = {result_experiment.RUSboost.validation_results.validation_sensitivity};
results_training("RUSboost", "Specificity") = {result_experiment.RUSboost.validation_results.validation_specificity};
results_training("RUSboost", "BCR") = {(result_experiment.RUSboost.validation_results.validation_sensitivity + result_experiment.RUSboost.validation_results.validation_specificity) / 2};

test_results = struct();
result_experiment.RUSboost.test_results = test_results;

result_experiment.RUSboost.test_results.test_predictions = ...
    result_experiment.RUSboost.model.predictFcn(test_dataset);

C_test_RB = confusionmat(table2array(test_dataset(:, target_feature_name)), result_experiment.RUSboost.test_results.test_predictions);
TP = C_test_RB(1, 1);
TN = C_test_RB(2, 2);
FP = C_test_RB(2, 1);
FN = C_test_RB(1, 2);

metrics = metrics_function(TP, TN, FP, FN);

result_experiment.RUSboost.test_results.test_accuracy = metrics.accuracy;
result_experiment.RUSboost.test_results.test_sensitivity = metrics.sensitivity;
result_experiment.RUSboost.test_results.test_specificity = metrics.specificity;
result_experiment.RUSboost.test_results.test_BCR = metrics.BCR;

results_test("RUSboost", "Accuracy")= {result_experiment.RUSboost.test_results.test_accuracy};
results_test("RUSboost", "Sensitivity")= {result_experiment.RUSboost.test_results.test_sensitivity};
results_test("RUSboost", "Specificity")= {result_experiment.RUSboost.test_results.test_specificity};
results_test("RUSboost", "BCR") = {result_experiment.RUSboost.test_results.test_BCR};

%% Training Random Forest model
fprintf("\n===================================================================\n");
fprintf("Training model using Random Forest with k=%d\n", k);
fprintf("===================================================================\n");

result_experiment.RandomForest = random_forest_function(training_dataset, target_feature_name, max_objective_evaluations, k);

results_training("RandomForest", "Accuracy") = {result_experiment.RandomForest.validation_results.validation_accuracy};
results_training("RandomForest", "Sensitivity") = {result_experiment.RandomForest.validation_results.validation_sensitivity};
results_training("RandomForest", "Specificity") = {result_experiment.RandomForest.validation_results.validation_specificity};
results_training("RandomForest", "BCR") = {(result_experiment.RandomForest.validation_results.validation_sensitivity + result_experiment.RandomForest.validation_results.validation_specificity) / 2};

test_results_RF = struct();
result_experiment.RandomForest.test_results = test_results_RF;

result_experiment.RandomForest.test_results.test_predictions = ...
    result_experiment.RandomForest.model.predictFcn(test_dataset);

C_test_RF = confusionmat(table2array(test_dataset(:, target_feature_name)), result_experiment.RandomForest.test_results.test_predictions);
TP = C_test_RF(1, 1);
TN = C_test_RF(2, 2);
FP = C_test_RF(2, 1);
FN = C_test_RF(1, 2);

metrics = metrics_function(TP, TN, FP, FN);

result_experiment.RandomForest.test_results.test_accuracy = metrics.accuracy;
result_experiment.RandomForest.test_results.test_sensitivity = metrics.sensitivity;
result_experiment.RandomForest.test_results.test_specificity = metrics.specificity;
result_experiment.RandomForest.test_results.test_BCR = metrics.BCR;

results_test("RandomForest", "Accuracy") = {result_experiment.RandomForest.test_results.test_accuracy};
results_test("RandomForest", "Sensitivity") = {result_experiment.RandomForest.test_results.test_sensitivity};
results_test("RandomForest", "Specificity") = {result_experiment.RandomForest.test_results.test_specificity};
results_test("RandomForest", "BCR") = {result_experiment.RandomForest.test_results.test_BCR};

%% Save results in xlsx files + save the structure with the trained models
writetable(results_training, "experiment_results_training.xlsx", 'WriteRowNames',true);
writetable(results_test, "experiment_results_test.xlsx", 'WriteRowNames',true);
save("result_experiment_trained_model.mat", "result_experiment");

%% EXPLAINABILITY - Visualization : 1. Plot the Feature Importance
% 
% Plot the feature importance for both RUSBoost and Random Forest models.
% The number of top features to display can be specified for each model.

% Parameters:
%   - result_experiment.RUSboost.feature_importance: Importance scores for RUSBoost model
%   - result_experiment.random_forest.feature_importance: Importance scores for Random Forest model
%   - top_n: Number of top features to display in the plot (e.g., 8 for RUSBoost, 10 for Random Forest)
%   - model_name: Name of the model for display purposes

% For RUSBoost
top_n_RUSboost = 8;  % Define how many top features to display
plot_importance(result_experiment.RUSboost.feature_importance, 'Feeding vs Other', top_n_RUSboost, 'RUSBoost');

% For Random Forest
top_n_RF = 10;  % Define how many top features to display
plot_importance(result_experiment.RandomForest.feature_importance, 'Feeding vs Other', top_n_RF, 'Random Forest');

%% 2. Plot the Partial Dependence Plots (PDP) for the Best Models
% Generate Partial Dependence Plots (PDP) for specific features in both models.
% You can specify one or more feature indices to examine their influence on predictions.

% Parameters:
%   - model: The trained model (e.g., RUSBoost, Random Forest)
%   - feature_index: Index or list of indices of the feature(s) for which to generate the PDP
%   - title_suffix: Text added to the plot title for clarity on which model is used
%   - class_names: Class names for the target variable in the model

% For RUSBoost
feature_indices_RUSboost = [1, 2];  % Define the features to plot PDP for RUSBoost
for feature_index = feature_indices_RUSboost
    plot_partial_dependence(result_experiment.RUSboost.model, feature_index, ...
        sprintf('Feeding vs Other (RUSBoost, Feature %d)', feature_index), ...
        result_experiment.RUSboost.model.ClassificationEnsemble.ClassNames);
end

% For Random Forest
feature_indices_RF = [1, 3];  % Define the features to plot PDP for Random Forest
for feature_index = feature_indices_RF
    plot_partial_dependence(result_experiment.random_forest.model, feature_index, ...
        sprintf('Feeding vs Other (Random Forest, Feature %d)', feature_index), ...
        result_experiment.RandomForest.model.ClassificationEnsemble.ClassNames);
end
