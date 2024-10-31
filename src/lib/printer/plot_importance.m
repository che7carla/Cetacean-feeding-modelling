function plot_importance(feature_importance, nameDataset, num_features, modelName)
    % PLOT_IMPORTANCE This function plots a bar chart for feature importance scores.
    %
    % Input:
    %   1) feature_importance - A table with the feature importance scores.
    %   2) nameDataset - The name of the dataset for which the feature importance is computed.
    %   3) num_features - Number of top features to display.
    %   4) modelName - The name of the model used (e.g., 'Random Forest', 'RUSBoost').

    % Convert table to array and get feature names
    FI_score = table2array(feature_importance);
    feature_names = feature_importance.Properties.RowNames;

    % Sort features by importance score in descending order
    [sorted_scores, sort_idx] = sort(FI_score, 'descend');
    sorted_names = feature_names(sort_idx);

    % Limit to the top N features if specified
    if nargin > 2 && num_features < length(sorted_scores)
        sorted_scores = sorted_scores(1:num_features);
        sorted_names = sorted_names(1:num_features);
    end

    % Plot the bar chart
    bar(sorted_scores);
    xlabel('Predictor rank');
    ylabel('Predictor importance score');
    xticklabels(strrep(sorted_names, '_', '_'));
    xtickangle(45);
    title(['Feature Importance - ' nameDataset ' (' modelName ')']);
    set(gca, 'TickLabelInterpreter', 'none');
end

