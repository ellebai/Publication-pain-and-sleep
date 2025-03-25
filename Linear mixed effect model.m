
% PLV_mean(subjects, states, frequencies, areas)
% X: covariates,[age,sex,group]
% group_col: groups (1=HC, 2=P)
% sleep_states: sleep stages
% areas: brain regions
% state_area_p: name of the results

T = readtable('H:\Usb Drivе\results\cov_71_del8.xlsx');
X = table2array(T(:,2:4));
group_col = X(:, end);
sleep_states = {'W', 'N1', 'N2', 'N3', 'REM'};
areas ={'f','t','c','p','o'}; 
frequencies = {'Slow Oscillation', 'Delta', 'Theta', 'Alpha', 'Beta', 'Gamma'};

p_values = [];  
state_area_p = []; 
anova_results= [];

for state = 1:5
    for area = 1:5       
        plv_data = squeeze(PLV_mean(:, state, :, area)); 
        data = [];
        for subj = 1:size(plv_data, 1)
            for freq = 1:length(frequencies)
                data = [data; ...
                    subj, group_col(subj), frequencies(freq), plv_data(subj, freq)];
            end
        end

        data_table = array2table(data, 'VariableNames', {'Subject', 'Group', 'Frequency', 'PLV'});     
        data_table.Group = categorical(string(data_table.Group));
        data_table.Subject = categorical(string(data_table.Subject));
        data_table.PLV = cell2mat(data_table.PLV);
        data_table.Frequency = categorical(string(data_table.Frequency));
        lme = fitlme(data_table, ...
            'PLV ~ Frequency * Group + (1|Subject)', ...
            'FitMethod', 'REML');

        anovas = anova(lme, 'DFMethod', 'Satterthwaite');             
        anova_results = [anova_results;{anovas}];
        p_anova = reshape(anovas.pValue(2:4),3, [])';
        p_values = [p_values; p_anova];
        state_area_p = [state_area_p; {sleep_states{state}, areas{area}}];
    end
end

p_values_cell = cell(25, 3);
p_values_cell(:, 1:3) = num2cell(p_values);
p=cat(2,state_area_p,p_values_cell);