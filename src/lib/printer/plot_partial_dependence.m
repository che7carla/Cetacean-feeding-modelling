function plot_partial_dependence(model, predictorIndex, nameDataset, classNames)
    % PLOT_PARTIAL_DEPENDENCE This function plots a partial dependence plot.
    %
    % Input:
    %   1) model - The trained classification ensemble model.
    %   2) predictorIndex - The index of the predictor for which to plot partial dependence.
    %   3) nameDataset - The name of the dataset for which the plot is generated.
    %   4) classNames - The class names for which the partial dependence is plotted.
    
    % Generate the partial dependence plot
    plotPartialDependence(model.ClassificationEnsemble, predictorIndex, classNames);
    title(['Partial Dependence Plot - ' nameDataset]);
    ylabel('Predicted scores');
end
