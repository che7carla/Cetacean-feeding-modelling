% Clear workspace, close figures, and clear command window for a clean start
clear all;
clc;
close all;

% Add path and directory
addpath(genpath("..\..\lib\config\"));
load_path_CFMs();

% Define a generic variable for the dataset: in this case the dataset with
% the environmental variables extraxted for all the Gulf of Taranto area,
% to make extrapolation.
dataset = 'dt_Got.xlsx';

% Load the dataset into a table format for processing.
dataTable = readtable(dataset);

% Extract relevant features from the dataset for prediction.
dataFeatures = dataTable(:, 1:6);

% Load the trained model.
trainedModelFile = 'result_experiment_trained_model.mat'; %use the name of the best model for the species
load(trainedModelFile);

% Use the trained model to make predictions on the loaded data.
predictedLabels = result_experiment.RUSboost.model.predictFcn(dataFeatures);

% Display the count of each predicted label category.
groupcounts(predictedLabels);

% Add the predicted labels as a new column in the data table.
dataTable.label = predictedLabels;

% Save the results with predictions into a new file.
outputFile = 'predicted_labels_output.xlsx';
writetable(dataTable, outputFile);

% ------------------------------
% Daily Data Processing Example
% ------------------------------

% Define the path for the daily prediction data file.
dailyDataFile = 'predicted_labels_output.xlsx';

% Load the daily prediction data into a table.
% Modify the path as needed if using a different file.
dailyData = readtable(dailyDataFile);

% Add a column to represent the month extracted from the 'time' column.
% Assumes 'time' is in a date-compatible format.
dailyData.Month = month(dailyData.time);

% Initialize a table to store the summarized results.
summaryTable = table('Size', [0 6], ...
    'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'Latitude', 'Longitude', 'Month', 'FeedingCount', 'OtherCount', 'TotalCount'});

% Extract unique latitude and longitude pairs from the daily data.
uniquePoints = unique(dailyData(:, {'latitude', 'longitude'}), 'rows');

% Loop through each unique geographic point and month (June, July, August).
for i = 1:height(uniquePoints)
    for month = 6:8 % Loop over June, July, and August
        % Select rows corresponding to the current latitude, longitude, and month.
        rows = dailyData.latitude == uniquePoints.latitude(i) & ...
               dailyData.longitude == uniquePoints.longitude(i) & ...
               dailyData.Month == month;

        % Count occurrences for each label type.
        feedingCount = sum(dailyData.label(rows) == "Feeding");
        otherCount = sum(dailyData.label(rows) == "Other");
        totalCount = sum(rows); % Total occurrences for validation.

        % Add the summarized data into the summary table.
        newRow = {uniquePoints.latitude(i), uniquePoints.longitude(i), month, feedingCount, otherCount, totalCount};
        summaryTable = [summaryTable; newRow];
    end
end

% Display the summarized results table.
disp(summaryTable);

% ------------------------------
% Subset Data for Each Month
% ------------------------------

% Define an array for months to automate the process for each month.
months = [6, 7, 8]; % June, July, August
outputFileNames = {'june_summary.xlsx', 'july_summary.xlsx', 'august_summary.xlsx'};

% Loop through each month and create a subset with a label assignment.
for idx = 1:length(months)
    currentMonth = months(idx);
    monthSubset = summaryTable(summaryTable.Month == currentMonth, :);

    % Initialize a label column with zeros.
    monthSubset.label = zeros(height(monthSubset), 1);

    % Set the label to '1' where 'FeedingCount' is greater than 'OtherCount'.
    monthSubset.label(monthSubset.FeedingCount > monthSubset.OtherCount) = 1;

    % Display the count of each label for verification.
    groupcounts(monthSubset.label);

    % Save the results to a file.
    writetable(monthSubset, outputFileNames{idx});
end

% ------------------------------
% Notes for Open Source Usage:
% ------------------------------
% 1. To change the input dataset, simply update the 'dataset' variable.
% 2. Ensure that the loaded dataset matches the expected format.
% 3. The output files will be saved in the current working directory unless otherwise specified.
% 4. The prediction model loaded should be compatible with the feature structure of the input dataset.
% 5. This script is generalized for monthly data analysis, but adjustments can be made for different periods or locations.
