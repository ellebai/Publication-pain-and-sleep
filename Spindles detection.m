%% compute the spindles length, number and density

% T: participants' ID and name

T = readtable('H:\Usb Drivе\results\cov_71_del8.xlsx');
spindle_num = zeros(59, 1);
spindle_length = zeros(59, 1);
spindle_density = zeros(59,1);
for i = 1:59
    
    file_name = ['H:\Usb Drivе\results\spindle\results\', cell2mat(T.ID(i)), '_N2.mat'];
    if exist(file_name)
        
        load(file_name)
        spindle_num(i) = size(events,1);
        spindle_length(i) = additionalInfo.spindleTime;
        spindle_density(i)=(additionalInfo.srate*size(events,1))/(additionalInfo.endFrame-additionalInfo.startFrame);
        else
    fprintf('File not found: %s\n', file_name);
    end
    
end

%% compute the spindles spectral power

% fs: sampling rate
% temp: participants' ID and name
% sublist: participants' ID
% area: divided cortical into 5 areas include frontal lobe, temporal lobe, central area, parietal lobe, occipital lobe
% data: EEG data segments that include spindles
% data_mean: average of 'data' according to the 'area'
% col2: find spindles according to its frequency

fs = 512;

temp = readtable('H:\Usb Drivе\results\SP_PLV\data\1_71.xlsx');
sublist = temp.Var1;
SP = zeros(length(sublist), 5);
area = {[1:4,6,7], [8,12,13,17], [9,11], [14,16], [18,19]};
for isb =1: length(sublist)
    disp(isb)

    load(['H:\Usb Drivе\results\SP_PLV\data\Subject', sublist{isb}(4:end), '\reduced2_', sublist{isb},'.mat']);

    load(['H:\Usb Drivе\results\spindle\1-74\sub',sublist{isb}(4:end), '_N2.mat']);
    
    events = round(events * fs);
    flag = zeros(length(reduced.data), 1);
    for j=1: size(events,1)
        flag(events(j,1):events(j,2))=1;
    end

    col = find(flag == 1);
    data = reduced.data(:, col);
    data_mean = zeros(length(area), size(data, 2));
        for g=1:5
           data_mean(g, :) = mean(data(area{g}, :), 1);
        end

    temp_sp = zeros(5, 1);
    for ipf = 1 : length(col)/ (30 * fs)
        data_temp = data_mean(:, 1+ (ipf-1)*30*fs : ipf*30*fs );
        [spectra, freqs] = spectopo(data_temp, length(data_temp), fs, 'boundaries', [], 'plot', 'off',  'freqfac',4 , 'winsize', fs*4, 'overlap', fs*2);

        col2 = find(freqs >=11 & freqs < 17);
        temp_sp = temp_sp + sum(spectra(:, col2),2);
    end
    SP(isb, :) = temp_sp/(length(col)/(30*fs));

end
