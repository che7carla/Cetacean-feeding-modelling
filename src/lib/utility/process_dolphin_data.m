function process_dolphin_data(input_filename, output_prefix)
    % process_dolphin_data - Processes dolphin behaviour data and generates
    % datasets for each species and environmental variable groups.
    %
    % Syntax:
    % process_dolphin_data(input_filename, output_prefix)
    %
    % Inputs:
    % input_filename - Name of the input Excel file containing the raw dataset (e.g., 'dataset.xlsx').
    % output_prefix - Prefix for the output file names (e.g., 'dt_g' for Grampus griseus).

    % Load the original dataset containing the 3 species and 4 behaviors
    dataset = readtable(input_filename);

    % Generate the dataset for the three species by filtering rows from the original one.
    dt_grampus = dataset(dataset.Species == "Grampus griseus", :);
    dt_striped = dataset(dataset.Species == "Stenella coeruleoalba", :);
    dt_bottlenose = dataset(dataset.Species == "Tursiops truncatus", :);

    % Modify the labels of the behaviours: retain 'Feeding' and rename others to 'Other'
    dt_grampus.Behaviour(ismember(dt_grampus.Behaviour, {'Socializing', 'Travelling', 'Resting'})) = {'Other'};
    dt_striped.Behaviour(ismember(dt_striped.Behaviour, {'Socializing', 'Travelling', 'Resting'})) = {'Other'};
    dt_bottlenose.Behaviour(ismember(dt_bottlenose.Behaviour, {'Socializing', 'Travelling', 'Resting'})) = {'Other'};

    % Select only the response variable (Behaviour) and the environmental predictors
    dt_g = dt_grampus(:, [1, 3, 7:26]);
    dt_g.Behaviour = cellstr(dt_g.Behaviour); % Convert the categorical column to a cell array

    dt_s = dt_striped(:, [1, 3, 7:26]);
    dt_s.Behaviour = cellstr(dt_s.Behaviour); % Convert the categorical column to a cell array

    dt_t = dt_bottlenose(:, [1, 3, 7:26]);
    dt_t.Behaviour = cellstr(dt_t.Behaviour); % Convert the categorical column to a cell array

    % Save the processed datasets with all environmental variables
    writetable(dt_g, [output_prefix, '_g.xlsx']);
    writetable(dt_s, [output_prefix, '_s.xlsx']);
    writetable(dt_t, [output_prefix, '_t.xlsx']);

    % Generate the datasets for the Physiographic variables
    dt_g_fisio = dt_g(:, [1:4]);
    dt_s_fisio = dt_s(:, [1:4]);
    dt_t_fisio = dt_t(:, [1:4]);

    writetable(dt_g_fisio, [output_prefix, '_g_fisio.xlsx']);
    writetable(dt_s_fisio, [output_prefix, '_s_fisio.xlsx']);
    writetable(dt_t_fisio, [output_prefix, '_t_fisio.xlsx']);

    % Generate the datasets for the Bio-chemical variables
    dt_g_bio = dt_g(:, [1, 2, 13, 14, 19:22]);
    dt_s_bio = dt_s(:, [1, 2, 13, 14, 19:22]);
    dt_t_bio = dt_t(:, [1, 2, 13, 14, 19:22]);

    writetable(dt_g_bio, [output_prefix, '_g_bio.xlsx']);
    writetable(dt_s_bio, [output_prefix, '_s_bio.xlsx']);
    writetable(dt_t_bio, [output_prefix, '_t_bio.xlsx']);

    % Generate the datasets for the Physical variables
    dt_g_fisic = dt_g(:, [1, 2, 5:12]);
    dt_s_fisic = dt_s(:, [1, 2, 5:12]);
    dt_t_fisic = dt_t(:, [1, 2, 5:12]);

    writetable(dt_g_fisic, [output_prefix, '_g_fisic.xlsx']);
    writetable(dt_s_fisic, [output_prefix, '_s_fisic.xlsx']);
    writetable(dt_t_fisic, [output_prefix, '_t_fisic.xlsx']);

    % Generate the datasets for the Inorganic nutrients
    dt_g_ino = dt_g(:, [1, 2, 15:18]);
    dt_s_ino = dt_s(:, [1, 2, 15:18]);
    dt_t_ino = dt_t(:, [1, 2, 15:18]);

    writetable(dt_g_ino, [output_prefix, '_g_ino.xlsx']);
    writetable(dt_s_ino, [output_prefix, '_s_ino.xlsx']);
    writetable(dt_t_ino, [output_prefix, '_t_ino.xlsx']);

    % Display a message indicating the completion of the process
    fprintf('Data processing completed. Files saved with prefix: %s\n', output_prefix);
end
