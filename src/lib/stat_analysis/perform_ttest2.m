function perform_ttest2(input_filename, output_filename_pvalues, output_filename_significant)
    % performTTestWithBonferroni - Performs two-sided t-tests between the 
    % "Feeding" and "Other" classes for each environmental variable and applies the Bonferroni correction.
    %
    % Syntax:
    % performTTestWithBonferroni(input_filename, output_filename_pvalues, output_filename_significant)
    %
    % Inputs:
    % input_filename - Name of the Excel file containing the dataset.
    % output_filename_pvalues - Name of the Excel file to save the p-values.
    % output_filename_significant - Name of the Excel file to save the significance results.

    % Read the dataset
    data = readtable(input_filename);

    % Create indices to select rows for the two different behaviors
    idx_feeding = strcmp("Feeding", data.Behaviour);
    idx_other = strcmp("Other", data.Behaviour);

    % Convert the table to an array (selecting only numerical variable columns)
    T = table2array(data(:, 3:22));

    % Number of columns (variables) to analyze
    num_col = size(T, 2);
    p_values = zeros(1, num_col);

    % Iterate through the columns to perform the t-tests
    for col = 1:num_col
        % Perform a two-sided t-test for the current column
        [~, p] = ttest2(T(idx_feeding, col), T(idx_other, col), "Tail", "both");

        % Store the p-value in the results array
        p_values(col) = p;
    end

    % Apply the Bonferroni correction
    alpha = 0.05; % Original significance level
    num_tests = length(p_values); % Total number of tests performed
    adjusted_alpha = alpha / num_tests; % Bonferroni correction

    % Compare each p-value with the adjusted alpha
    significant_results = p_values < adjusted_alpha;

    % Convert the p-values to a table for better visualization
    p_values_table = array2table(p_values, 'VariableNames', data.Properties.VariableNames(3:22));
    significant_results_table = array2table(significant_results, 'VariableNames', data.Properties.VariableNames(3:22));

    % Save the results to Excel files
    writetable(p_values_table, output_filename_pvalues);
    writetable(significant_results_table, output_filename_significant);

    % Display a message indicating that the results have been saved
    fprintf('The t-test results have been saved in %s and %s.\n', output_filename_pvalues, output_filename_significant);
end
