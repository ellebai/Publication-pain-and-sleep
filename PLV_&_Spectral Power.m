
% sublist: participants' ID
% bandcenter: frequency of band center
% bandwidth: frequency of band width
% fs: sampling rate
% states: sleep satges
% area: divided cortical into 5 regions include frontal lobe, temporal lobe, central area, parietal lobe, occipital lobe
% PLV_mean: store the mean of phase locking valule
% PLV_std: store the standard deviation of phase locking valule
% SP: store the spectral power of spindles
% temp2: every frame and its sleep stages
% set:  sleep stage of each frame
% data: EEG data throughout sleep
% data_mean: average of 'data' according to the 'area'

%% compute the phase locking value and spectral power of neural network oscillations in different brain regions

% Phase locking value were compute by HERMES Toolbox
% addpath(genpath("D:\Softwares\EEG\HERMES Toolbox 2020-04-26\HERMES Toolbox"))

temp = readtable('H:\Usb Drivе\results\SP_PLV\data\1_71.xlsx');
sublist = temp.Var1;

bandcenter =15.25;
bandwidth =29.5;

fs = 512;
window = struct('length', 30000 ,'overlap',0,'alignment','epoch','fs', fs,'baseline',0);
states = {'W','N1', 'N2', 'N3', 'REM'};
area = {[1:4,6,7], [8,12,13,17], [9,11], [14,16], [18,19]};

PLV_mean = zeros(length(sublist), length(states), length(bandcenter), 10);
PLV_std = zeros(length(sublist), length(states), length(bandcenter), 10);
SP = zeros(length(sublist), length(states), length(bandcenter), 5);
for isb =1: length(sublist)
    disp(isb)
    
    load(['H:\Usb Drivе\results\SP_PLV\data\Subject', sublist{isb}(4:end), '\reduced2_', sublist{isb},'.mat']);
    temp2 = readtable(['H:\Usb Drivе\results\SP_PLV\data\Subject', sublist{isb}(4:end), '\', sublist{isb},'.xlsx']);
    
    for ist =1: length(states)
        
        set = temp2.Set1;        
        col_temp = strfind(set, states{ist});
        label = zeros(length(col_temp), 1);
        for t = 1 : length(col_temp)
            label(t) = isempty(col_temp{t});
        end      
        epochs = find(~label);
             
        flag = zeros(length(reduced.data), 1);
        for k = 1 : length(epochs)
            flag( (epochs(k)-1)*fs*30+1:epochs(k)*fs*30 ) = 1;
        end
        col = find(flag == 1);
        data = reduced.data(:, col);
        
        data_mean = zeros(length(area), size(data, 2));
        for g=1:5
           data_mean(g, :) = mean(data(area{g}, :), 1);
        end
        
        if ~isempty(data_mean)

        for ib = 1 : length(bandwidth)
            
            config = struct('measures','PLV','bandcenter',bandcenter(ib),'bandwidth',bandwidth(ib),'method','ema','window', window);
            output_PLV = H_methods_PS(data_mean',config);
                         
            index_temp = 1;
            for i = 1 : 5
                for j = i +1 : 5
                    PLV_mean(isb, ist, ib, index_temp) = mean(output_PLV.PLV.data(i,j,1,:));
                    PLV_std(isb, ist, ib, index_temp) = std(output_PLV.PLV.data(i,j,1,:));
                    index_temp = index_temp + 1;
                end
            end
                      
            temp_sp = zeros(5, 1);
            for ipf = 1 : length(epochs)
               data_temp = data_mean(:, 1+ (ipf-1)*30*fs : ipf*30*fs );
               [spectra, freqs] = spectopo(data_temp, length(data_temp), fs, 'boundaries', [], 'plot', 'off',  'freqfac',4 , 'winsize', fs*4, 'overlap', fs*2);
                
               col2 = find(freqs >= bandcenter(ib)-bandwidth(ib)/2 & freqs < bandcenter(ib)+bandwidth(ib)/2);
               temp_sp = temp_sp + sum(spectra(:, col2),2);
            end
            SP(isb, ist, ib, :) = temp_sp/length(epochs);
            
        end
    end
    end
end      

%% compute the phase locking value and spectral power across multiple neural network oscillations (slow oscillation, delta, theta, alpha,beta,gamma) in different brain regions

temp = readtable('H:\results\SP_PLV\data\1_71.xlsx');
sublist = temp.Var1;

bandcenter = [0.75 2.5 6 10 13.5 22.5];
bandwidth = [0.5 3 4 4 3 15];
fs = 512;
window = struct('length', 30000 ,'overlap',0,'alignment','epoch','fs', fs,'baseline',0);  
states = {'W','N1', 'N2', 'N3', 'REM'};
area = {[1:4,6,7], [8,12,13,17], [9,11], [14,16], [18,19]};

PLV_mean = zeros(length(sublist), length(states), length(bandcenter), 10);
PLV_std = zeros(length(sublist), length(states), length(bandcenter), 10);
SP = zeros(length(sublist), length(states), length(bandcenter), 5);
for isb =1: length(sublist)
    disp(isb)
    
    load(['H:\results\SP_PLV\data\Subject', sublist{isb}(4:end), '\reduced2_', sublist{isb},'.mat']);
     temp2 = readtable(['H:\results\SP_PLV\data\Subject', sublist{isb}(4:end), '\', sublist{isb},'.xlsx']);
    
    for ist =1: length(states)
              
        set = temp2.Set1;    
        col_temp = strfind(set, states{ist});
        label = zeros(length(col_temp), 1);
        for t = 1 : length(col_temp)
            label(t) = isempty(col_temp{t});
        end
        label = find(~label);
        epochs = temp2.Epoch(label);
        
        flag = zeros(length(reduced.data), 1);
        for k = 1 : length(epochs)
            flag( (epochs(k)-1)*fs*30+1:epochs(k)*fs*30 ) = 1;
        end
        col = find(flag == 1);
        data = reduced.data(:, col);
        data_mean = zeros(length(area), size(data, 2));
        for g=1:5
           data_mean(g, :) = mean(data(area{g}, :), 1);
        end
        
        if ~isempty(data_mean)

        for ib = 1 : length(bandwidth)
            
            %compute Phase locking value
            config = struct('measures','PLV','bandcenter',bandcenter(ib),'bandwidth',bandwidth(ib),'method','ema','window', window);
            output_PLV = H_methods_PS_Zhang(data_mean',config);
                         
            index_temp = 1;
            for i = 1 : 5
                for j = i +1 : 5
                    PLV_mean(isb, ist, ib, index_temp) = mean(output_PLV.PLV.data(i,j,1,:));
                    PLV_std(isb, ist, ib, index_temp) = std(output_PLV.PLV.data(i,j,1,:));
                    index_temp = index_temp + 1;
                end
            end
            
            temp_sp = zeros(5, 1);
            for ipf = 1 : length(epochs)
               data_temp = data_mean(:, 1+ (ipf-1)*30*fs : ipf*30*fs );
               [spectra, freqs] = spectopo(data_temp, length(data_temp), fs, 'boundaries', [], 'plot', 'off',  'freqfac',4 , 'winsize', fs*4, 'overlap', fs*2);
                
               col2 = find(freqs >= bandcenter(ib)-bandwidth(ib)/2 & freqs < bandcenter(ib)+bandwidth(ib)/2);
               temp_sp = temp_sp + sum(spectra(:, col2),2);
            end
            SP(isb, ist, ib, :) = temp_sp/length(epochs);
            
        end
    end
    end
end   
