function start_process(handles)
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
[file, folder] = uigetfile({'*.txt', 'Acceleration file (*.txt)'}, 'Please select a file');
if file==0
    return
else
    % Clear previous status
    clear_status(handles);
end

set(handles.root, 'pointer', 'watch');
filenames = strsplit(file, '_');
file_id = filenames{3}; % File id (name of the file)
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
        disp_error(handles, 'Please check that N-S (_N), E-W (_E) y Z (_Z) files exist in the same folder.', ...
            'Error');
        return
    end
end

%% Files are loaded
try
    data_ns = load(strcat(folder, files{1}));
    data_ew = load(strcat(folder, files{2}));
    data_z = load(strcat(folder, files{3}));
catch
    disp_error(handles, 'An error has occurred while loading the files.', 'Error');
    return
end

%% Store acceleration and time data from files
ns_acc = data_ns(:, 2);
ew_acc = data_ew(:, 2);
z_acc = data_z(:, 2);

ns_t = data_ns(:, 1);
ew_t = data_ew(:, 1);
z_t = data_z(:, 1);

%% Data width
ns_acc_len = length(ns_acc);
ew_acc_len = length(ew_acc);
z_acc_len = length(z_acc);

%% Baseline correction
ns_acc = detrend(ns_acc);
ew_acc = detrend(ew_acc);
z_acc = detrend(z_acc);

%% Smoothing tuckey
ven_ns = tukeywin(ns_acc_len, 0.05);
ven_ew = tukeywin(ew_acc_len, 0.05);
ven_z = tukeywin(z_acc_len, 0.05);

ns_acc_v = ven_ns .* ns_acc;
ew_acc_v = ven_ew .* ew_acc;
z_acc_v = ven_z .* z_acc;

%% Smoothing tuckey is plotted
axes(handles.plot_ns_v);
plot(ns_t, ns_acc_v ./ G_VALUE, STYLE_TUCKEY_PLOT);
hold on;
xlim([0 max(ns_t)]);
yaxis_linspace(5);
xaxis_linspace(6);
grid on;
axes(handles.plot_ew_v);
plot(ew_t, ew_acc_v ./ G_VALUE, STYLE_TUCKEY_PLOT);
hold on;
xlim([0 max(ew_t)]);
yaxis_linspace(5);
xaxis_linspace(6);
grid on;
axes(handles.plot_z_v);
plot(z_t, z_acc_v ./ G_VALUE, STYLE_TUCKEY_PLOT);
hold on;
xlim([0 max(z_t)]);
yaxis_linspace(5);
xaxis_linspace(6);
grid on;

%% Pick FFT region
switch PICK_MODE
    case 1    
        fig_obj = figure('Name', 'Pick a region to start FFT calculation', ...
            'NumberTitle', 'off');
        plot(ns_t, ns_acc_v ./ G_VALUE, 'k');
        xlim([0 max(ns_t)]);
        xlabel('Time (s)');
        ylabel('Acceleration (g)');
        grid on;
        movegui(fig_obj, 'center');
        try
            fft_region = ginput(2);
            lim1 = fft_region(1, 1);
            lim2 = fft_region(2, 1);
            close(fig_obj);
        catch
            disp_error(handles, 'If region is not selected process cant continue.', 'Error');
            return
        end
        if lim1==lim2
            disp_error(handles, 'Region limits cant be the same.', 'Error');
            return
        end
    case 2
        fig_obj = figure('Name', 'Pick a point to select 30 seconds range', ...
            'NumberTitle', 'off');
        plot(ns_t, ns_acc_v ./ G_VALUE, 'k');
        xlim([0 max(ns_t)]);
        xlabel('Time (s)');
        ylabel('Acceleration (g)');
        grid on;
        movegui(fig_obj, 'center');
        try
            lim1 = ginput(1);
            lim1(1)
            max(ns_t)
            close(fig_obj);
        catch
            disp_error(handles, 'If region is not selected process cant continue.', 'Error');
            return
        end
    otherwise
        disp_error(handles, 'Invalid pick mode, PICK_MODE must be 1 or 2.', 'Configuration error');
        return
end

%% Draw selected region on Tuckey plots
axes(handles.plot_ns_v);
draw_vx_line(lim1, STYLE_HALF_PLOT_TUCKEY);
draw_vx_line(lim2, STYLE_HALF_PLOT_TUCKEY);
axes(handles.plot_ew_v);
draw_vx_line(lim1, STYLE_HALF_PLOT_TUCKEY);
draw_vx_line(lim2, STYLE_HALF_PLOT_TUCKEY);
axes(handles.plot_z_v);
draw_vx_line(lim1, STYLE_HALF_PLOT_TUCKEY);
draw_vx_line(lim2, STYLE_HALF_PLOT_TUCKEY);

%% Count elements between lim1 and lim2
t_len = 0;
for i=1:length(ns_t)
    if lim2>=ns_t(i) && ns_t(i)>=lim1
        t_len = t_len + 1;
    end
end

%% Create new arrays
t_arr = zeros(t_len, 1);
new_ns_acc = zeros(t_len, 1);
new_ew_acc = zeros(t_len, 1);
new_z_acc = zeros(t_len, 1);

j = 1; % Index to store values
cumtime = 0;
dt = ns_t(2)-ns_t(1);
for i=1:length(ns_t)
    if lim2>=ns_t(i) && ns_t(i)>=lim1
        t_arr(j) = cumtime;
        new_ns_acc(j) = ns_acc(i);
        new_ew_acc(j) = ew_acc(i);
        new_z_acc(j) = z_acc(i);
        j = j + 1;
        cumtime = cumtime + dt;
    end
end

%% FFT to new arrays
try
    fft_ns = real(fft(new_ns_acc));
    fft_ew = real(fft(new_ew_acc));
    fft_z = real(fft(new_z_acc));
catch
    disp_error(handles, 'An error has occured while calculating FFT.', 'Fatal error');
    return
end

%% Select half of data
t_len_h = floor(t_len/2);
t_arr_h = t_arr(1: t_len_h);
fft_ns_h = fft_ns(1: t_len_h);
fft_ew_h = fft_ew(1: t_len_h);
fft_z_h = fft_z(1: t_len_h);

%% Plot FFT
axes(handles.plot_fft_ns);
plot(t_arr_h, fft_ns_h, STYLE_FFT_PLOT);
xlim([0 max(t_arr_h)]);
xaxis_linspace(7);
yaxis_linspace(5);
hold on;
grid on;
axes(handles.plot_fft_ew);
plot(t_arr_h, fft_ew_h, STYLE_FFT_PLOT);
xlim([0 max(t_arr_h)]);
xaxis_linspace(7);
yaxis_linspace(5);
hold on;
grid on;
axes(handles.plot_fft_z);
plot(t_arr_h, fft_z_h, STYLE_FFT_PLOT);
xlim([0 max(t_arr_h)]);
xaxis_linspace(7);
yaxis_linspace(5);
hold on;
grid on;

%% Finishes process
set(handles.root, 'pointer', 'arrow');
end