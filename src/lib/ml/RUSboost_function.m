%% Function to train and test a random forest regression model
%% Input:
% 1) trainingDataset: 
% Table containing the input features (predictor) and output feature (response)  
%
% 2) targetFeatureName: 
% String with the name of the output feature in the trainingData table.
%  
% 3) max_objective_evaluations:
% Maximum number of objective functions to be evaluated in the
% optimization process     
%
% 4) a number k to use in k-fold cross-validation

%% Output:
% Compact structure with the following data:
% 1) trainedMod
% 
% el:
% Struct containing the trained classification model. The
% struct contains various fields with information about the trained
% model. 
% trainedModel.predictFcn(): A function to make predictions on new data.
%
% 2) validationAccuracy: 
% Double number containing the accuracy which measure 
% the performance of the trained model.
%       
% 3) validationPredictions: 
% Vector with the predicted values with respect the observed values in the
% trainingDataset by the trained model
%      
% 4)featuresImportanceTable:
% Table with features and score which indicates how important is each 
% feature to train the model. Features have been ordered from the most 
% important to the least important.
%
% 5) tuningResult:
% Table with the optimized hyperparameters obtained by auto-tuning
% procedure

function [results] = RUSboost_function(trainingDataset,targetFeatureName,max_objective_evaluations, k)
%% Extract predictors and response
inputTable = trainingDataset;

% Retrive all the input features (predictors) to be used in the training process
predictorNames = inputTable.Properties.VariableNames;
predictorNames(:,(strncmp(predictorNames, targetFeatureName,...
        strlength(targetFeatureName)))) = [];
predictorNames = predictorNames(2:end); 
predictors = inputTable(:, predictorNames);

% Retrive the output feature (response)
response = inputTable(:, targetFeatureName);

% Set configuration for k-fold cross validation
%n_observations = height(response);
%cross_validation_settings = cvpartition(n_observations,'KFold',k);
group=table2array(response)
cross_validation_settings = cvpartition(group,'KFold',k);
%% Set parameters to be optimized during the auto-tuning procedure

RUSboost_settings_optimized = fitcensemble( ...
    predictors, ... 
    response, ...
    'Method', 'RUSboost', ...
    'OptimizeHyperParameters',...
    {'NumLearningCycles', 'LearnRate','MaxNumSplits'}, ...
    "HyperparameterOptimizationOptions", ...
    struct(...
    "AcquisitionFunctionName","expected-improvement-per-second-plus", ...
    'CVPartition', cross_validation_settings, ...
    "MaxObjectiveEvaluations", max_objective_evaluations,...
    "Repartition", false,...
    "UseParallel", true));



%% Retrive all the optimized hyperparameters and save them
nLearn = RUSboost_settings_optimized.ModelParameters.NLearn;
modelParams = ...
    struct(RUSboost_settings_optimized.ModelParameters.LearnerTemplates{1,1});
maxSplits = modelParams.ModelParams.MaxSplits;
lRate = RUSboost_settings_optimized.ModelParameters.LearnRate;

tuningResult = table('Size', [1 3], 'VariableTypes',...
   {'double','double','double'}, 'VariableNames',...
   {'nLearn', 'lRate','maxSplits'});

tuningResult.nLearn(1) = nLearn;
tuningResult.lRate(1) = lRate;
tuningResult.maxSplits(1) = maxSplits;

%% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
ensemblePredictFcn = @(x) predict(RUSboost_settings_optimized, x);
trainedModel.predictFcn = @(x) ensemblePredictFcn(predictorExtractionFcn(x));

%% Add additional fields to the result struct
trainedModel.RequiredVariables = trainingDataset.Properties.VariableNames;
%trainedModel.RegressionEnsemble = random_forest_settings_optimized;
trainedModel.ClassificationEnsemble = RUSboost_settings_optimized;

trainedModel.About = 'This struct is a RUSboost optimized trained model.';
trainedModel.HowToPredict = ...
    sprintf(['To make predictions on a new table, T, use: ' ...
    '\n  yfit = trainedModel.predictFcn(T) \n' ...
    '\n \nThe table, T, must contain the variables returned by: ' ...
    '\n  trainedModel.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype)' ...
    ' must match the original training data. \nAdditional variables are ignored. ' ...
    '\n \nFor more information, ' ...
    'see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ' ...
    '''appregression_exportmodeltoworkspace'')">How to predict using an exported model</a>.']);

%% Perform cross-validation with k fold
partitionedModel = crossval(trainedModel.ClassificationEnsemble, 'KFold', k);
validationPredictions = kfoldPredict(partitionedModel);
C_validation_RB=confusionmat(table2array(trainingDataset(:, targetFeatureName)), validationPredictions);
TP_val_RB = C_validation_RB(1, 1);
TN_val_RB = C_validation_RB(2, 2);
FP_val_RB = C_validation_RB(2, 1);
FN_val_RB = C_validation_RB(1, 2);
validationAccuracy_RB =(TP_val_RB+TN_val_RB)/(TP_val_RB+TN_val_RB+FN_val_RB+FP_val_RB);
validationSensitivity_RB = TP_val_RB / (FN_val_RB + TP_val_RB);
validationSpecificity_RB = TN_val_RB / (TN_val_RB + FP_val_RB);
validationBCR_RB= (validationSensitivity_RB + validationSpecificity_RB)/2;


 %% Compute features importance
featureImportance = predictorImportance(RUSboost_settings_optimized);
featuresImportanceTable = table('Size', [width(predictorNames) 1], 'VariableTypes',...
    {'double'}, 'VariableNames', {'score'},'RowNames', string(predictorNames'));
    featuresImportanceTable.score = featureImportance';
featuresImportanceTable = sortrows(featuresImportanceTable,'score','descend');
writetable(featuresImportanceTable, "Features_importance_RUSboost.xlsx", 'WriteRowNames',true);

%% Save all results from training process
validation_results = struct();
test_results = struct();

% Save predictions from model on validation observations
validation_results.validation_predictions = validationPredictions;

% Save accuracy and all the metrics from model on validation observations
validation_results.validation_accuracy = validationAccuracy_RB;
validation_results.validation_sensitivity= validationSensitivity_RB;
validation_results.validation_specificity = validationSpecificity_RB;
validation_results.validation_BCR = validationBCR_RB;



results = struct('model', trainedModel, ...
    'validation_results', validation_results, ...
    'test_results', test_results,...
    'feature_importance', featuresImportanceTable, ...
    'hyperparameters', tuningResult);
end