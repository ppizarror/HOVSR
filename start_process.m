function start_process(handles, lang)
% This function starts calculation process.
%
% Author: Pablo Pizarro @ppizarror.com, 2017.
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

%% Library import
config;
constants;

%% Select file
lastfolder = getappdata(handles.root, 'lasthandles_folder');
if ~strcmp(lastfolder, '')
    [file, folder] = uigetfile({'*.txt', lang{8}}, lang{9}, lastfolder);
else
    [file, folder] = uigetfile({'*.txt', lang{8}}, lang{9});
end
if file==0
    return
else
    % Clear previous status
    clear_status(handles, lang);
    
    % Save last folder
    setappdata(handles.root, 'lasthandles_folder', folder);
end

set(handles.root, 'pointer', 'watch');
filenames = strsplit(file, '_');
station_id = filenames{STATION_POS};
file_id = filenames{FILE_ID_POS}; % File id (name of the file)
file_t = get_type_file(file, file_id);

files = cell(3, 1); % Necessary files, 1: NS, 2: EW, 3: Z
files{file_t} = file;

%% Scan folder to find the rest of the files
folder_files = dir(folder);
for f = 1:length(folder_files)
    ft = get_type_file(folder_files(f).name, file_id);
    if ft
        files{ft} = folder_files(f).name;
    end
end

%% Check that all files are loaded
for k = 1:3
    % If a file is not loaded then function stops
    if isempty(files{k})
        disp_error(handles, 10, 15, lang);
        return
    end
end

%% Files are loaded
try
    data_ns = load(strcat(folder, files{1}));
    data_ew = load(strcat(folder, files{2}));
    data_z = load(strcat(folder, files{3}));
catch
    disp_error(handles, 12, 15, lang);
    return
end

%% Store acceleration and time data from files
ns_acc = data_ns(:, 2);
ew_acc = data_ew(:, 2);
z_acc = data_z(:, 2);

ns_t = data_ns(:, 1);
ew_t = data_ew(:, 1);
z_t = data_z(:, 1);

%% Checks that all files have the same size of elements
if length(ns_acc)~=length(ew_acc) && length(ew_acc)~=length(z_acc)
    disp_error(handles, 13, 14, lang);
    return
end

%% Calculate frecuency and dt
dt = ns_t(2)-ns_t(1);
f = 1/dt; % Sampling rate

%% Baseline correction
ns_acc = detrend(ns_acc, 0);
ew_acc = detrend(ew_acc, 0);
z_acc = detrend(z_acc, 0);

%% Acceleration data is plotted
axes(handles.plot_ns);
plot(ns_t, ns_acc, STYLE_ACCELERATION_PLOT);
hold on;
xlim([0 max(ns_t)]);
yaxis_linspace(5);
xaxis_linspace(6);
grid on;
axes(handles.plot_ew);
plot(ew_t, ew_acc, STYLE_ACCELERATION_PLOT);
hold on;
xlim([0 max(ew_t)]);
yaxis_linspace(5);
xaxis_linspace(6);
grid on;
axes(handles.plot_z);
plot(z_t, z_acc, STYLE_ACCELERATION_PLOT);
hold on;
xlim([0 max(z_t)]);
yaxis_linspace(5);
xaxis_linspace(6);
grid on;

%% Pick FFT region + windows
fig_obj = figure('Name', lang{7}, 'NumberTitle', 'off');
plot(ns_t, ns_acc ./ G_VALUE, 'k');
hold on;
plot(ns_t, ew_acc ./ G_VALUE, 'r');
plot(ns_t, z_acc ./ G_VALUE, 'b');
xaxis_linspace(7);
xlim([0 max(ns_t)]);
xlabel(lang{17});
ylabel(lang{18});
grid on;
movegui(fig_obj, 'center');
try
    data_region = ginput(2);
    data_region = [data_region(1, 1) data_region(2, 1)];
    lim1 = min(data_region);
    lim2 = max(data_region);
catch
    disp_error(handles, 16, 11, lang);
    return
end
if lim1==lim2
    disp_error(handles, 24, 11, lang);
    return
end
close(fig_obj);

%% Ask time and dt of windows
wsize = min(lim2-lim1, WINDOW_SIZE);
data = inputdlg({sprintf(lang{21}, lim2-lim1), lang{20}}, lang{19}, ...
    [1 50; 1 50], {num2str(wsize), num2str(WINDOW_MOVE)}); 
wtime = data{1};
wdt = data{2};

%% Check that wtime and wdt are numbers
if strcmp(wtime, 'i') || strcmp(wdt, 'i')
    disp_error(handles, 22, 23, lang);
    return
end

% Convert to number
try
    wtime = str2double(wtime);
    wdt = str2double(wdt);
catch
    disp_error(handles, 22, 23, lang);
    return
end

%% Window array length & Tuckey window

% Window array lengths
t_len = floor(wtime / dt);
t_len_h = floor(t_len/2);

% Create tuckey (5%)
tuckey = tukeywin(t_len, 0.05);

%% Create frecuency array & Konno-Ohmachi window
freq_arr = 0 : f/t_len: f - 1 / t_len;
freq_h = freq_arr(1: t_len_h); % Half of frequency

% Konno aplied to half of frequency
fc = freq_arr(floor(length(freq_h)/2) + 1);
konno = konno_ohmachi(freq_h, fc, 30)';

%% Calculate total iterations
totalitr = 1;
k = 1;
while true
    if k*wdt + wtime + lim1 <= lim2
        totalitr = totalitr + 1;
        k = k + 1;
    else
        break;
    end
end
process_timer(handles, lang, 0.001);

%% Start iteration process

% Sum of sh/sv to calculate mean
sum_shsv = zeros(t_len_h, 1);
max_freqs = zeros(totalitr, 1);
max_shsv = zeros(totalitr, 1);

tic;
re_accel = cell(6); % Lines of region plotted on acceleration plots
for itr=1:totalitr
    
    % Select iteration time limits
    ilim1 = wdt*(itr-1)+lim1;
    ilim2 = ilim1+wtime;
    
    % Plot window on accelration plots
    if SHOW_REGION_ON_ACCELERATION
        axes(handles.plot_ns);
        if itr>1
            delete(re_accel{1});
            delete(re_accel{2});
        end
        re_accel{1} = draw_vx_line(ilim1, STYLE_REGION_ACCEL);
        re_accel{2} = draw_vx_line(ilim2, STYLE_REGION_ACCEL);
        axes(handles.plot_ew);
        if itr>1
            delete(re_accel{3});
            delete(re_accel{4});
        end
        re_accel{3} = draw_vx_line(ilim1, STYLE_REGION_ACCEL);
        re_accel{4} = draw_vx_line(ilim2, STYLE_REGION_ACCEL);
        axes(handles.plot_z);
        if itr>1
            delete(re_accel{5});
            delete(re_accel{6});
        end
        re_accel{5} = draw_vx_line(ilim1, STYLE_REGION_ACCEL);
        re_accel{6} = draw_vx_line(ilim2, STYLE_REGION_ACCEL);
    end
    
    % Create new arrays
    ns_itr = zeros(t_len, 1);
    ew_itr = zeros(t_len, 1);
    z_itr = zeros(t_len, 1);

    j = 1; % Index to store values
    for i=1:length(ns_t)
        if ilim2>=ns_t(i) && ns_t(i)>=ilim1
            ns_itr(j) = ns_acc(i);
            ew_itr(j) = ew_acc(i);
            z_itr(j) = z_acc(i);
            j = j + 1;
        end
    end
    
    % Apply tuckey window
    ns_itr = ns_itr .* tuckey;
    ew_itr = ew_itr .* tuckey;
    z_itr = z_itr .* tuckey;
    
    % Apply fft
    ns_fft_itr = fft(ns_itr);
    ew_fft_itr = fft(ew_itr);
    z_fft_itr = fft(z_itr);
    
    % Select half of data
    fft_ns = ns_fft_itr(1: t_len_h);
    fft_ew = ew_fft_itr(1: t_len_h);
    fft_z = z_fft_itr(1: t_len_h);
    
    % Apply absolute value & konno
    fft_ns = abs(fft_ns).*konno;
    fft_ew = abs(fft_ew).*konno;
    fft_z = abs(fft_z).*konno;
    
    % Calculate SH
    sh = sqrt((fft_ns.^2 + fft_ew.^2)./2);
    sh_sv = sh./fft_z;
    
    % Delete NaN
    sh_sv(isnan(sh_sv)) = 0;
    
    % Add sh/sv to mean
    sum_shsv = sum_shsv + sh_sv;
    
    % Mean sh/sv
    mean_shsv = sum_shsv./itr;
    
    % Calculate maximum frecuency and sh/sv
    svsh_max = 0;
    maxf = 0;
    for j=1:length(freq_h)
        if mean_shsv(j) > svsh_max && freq_h(j)>MIN_F_SHSV
            svsh_max = mean_shsv(j);
            maxf = freq_h(j);
        end
        if freq_h(j) > MAX_F_SHSV
            break
        end
    end
    
    % Set MAX F and MAX SH/SV
    max_freqs(itr) = maxf;
    max_shsv(itr) = svsh_max;
    
    % Plot mean
    axes(handles.plot_avg_shsv); %#ok<*LAXES>
    plot(freq_h, mean_shsv, STYLE_AVERAGE_SHSV);
    xlim([MIN_F_SHSV MAX_F_SHSV]);
    
    grid on;
    yaxis_linspace(5);
    
    if SHOW_MAX_F_ON_AVERAGE_SHSV
        hold on;
        draw_vx_line(maxf, STYLE_MAX_F_ON_AVERAGE);
    end
    hold off;
    
    % Plot MAX F
    axes(handles.plot_maxf);
    plot(1:1:itr, max_freqs(1:itr), STYLE_MAX_F);
    xlim([1 max(itr, 2)]);
    yaxis_linspace(5);
    hold off;
    grid on;
    
    % Plot MAX SH/SV
    axes(handles.plot_maxshsv);
    plot(1:1:itr, max_shsv(1:itr), STYLE_MAX_SHSV);
    xlim([1 max(itr, 2)]);
    yaxis_linspace(5);
    hold off;
    grid on;

    % Change timer
    process_timer(handles, lang, itr/totalitr);
    pause(0.005);
    
end
exec_time = toc;
    
%% Finishes process
set(handles.root, 'pointer', 'arrow');

%% Enable buttons
set(handles.menu_export_results, 'Enable', 'on');
set(handles.button_exportresults, 'Enable', 'on');

%% Save data
setappdata(handles.root, 'results', true);
setappdata(handles.root, 'results_shsv', mean_shsv);
setappdata(handles.root, 'results_f', freq_h);

%% Show final statuses
if SHOW_ITR_MAXSHSV
    fig_obj = figure('Name', file, 'NumberTitle', 'off');
    movegui(fig_obj, 'center');
    setappdata(handles.root, 'figureid1', fig_obj);
    plot(freq_h, mean_shsv, STYLE_SHSV_F);
    hold on;
    draw_vx_line(max_freqs(end), STYLE_SHSV_MAXF);
    xlim([MIN_F_SHSV MAX_F_SHSV]);
    ylim([0 max(mean_shsv)*1.1]);
    grid on;
    xlabel(lang{31});
    ylabel(lang{32});
    title(lang{30});
end

if SHOW_ITR_DIALOG
    msgbox({sprintf(lang{25}, max_freqs(end)); sprintf(lang{26}, max_shsv(end)); ...
        ''; sprintf(lang{27}, totalitr); sprintf(lang{28}, exec_time)}, ...
        lang{29}, 'help');
end

end

