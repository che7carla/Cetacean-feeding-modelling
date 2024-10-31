%% Splitting dataset in training set and test set
%   dataset: the original dataset which we want to split in training set
%   and test set
%   test_dataset_size: Fraction or number of observations in the test set 
%   used for holdout validation
%USE THE STRAIFIED PARTITION
function [train_set,test_set] = create_training_test_dataset(dataset, test_dataset_size)    
% rng('shuffle') means that in each execution we obtain different split
   rng('shuffle');
   tgroup = tall(dataset.Behaviour);
   hpartition = cvpartition(tgroup,'Holdout',test_dataset_size) ; 
   idxTrain = gather(hpartition.training);
   train_set = dataset(idxTrain,:);
   testIdx = gather(hpartition.test);
   test_set = dataset(testIdx,:);
end
