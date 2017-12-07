function start_process(handles, lang)
% START PROCESS
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

%% Select files
lastfolder = getappdata(handles.root, 'lasthandles_folder');
if ~strcmp(lastfolder, '') && ~isnumeric(lastfolder)
    [file, folder] = uigetfile({'*.txt', lang{8}}, lang{9}, lastfolder, 'MultiSelect', 'on');
else
    [file, folder] = uigetfile({'*.txt', lang{8}}, lang{9}, 'MultiSelect', 'on');
end

% Get total files selected
[~, totalfiles] = size(file);

% Save last folder
setappdata(handles.root, 'lasthandles_folder', folder);

% If user does not selected 3 files
if totalfiles == 3 && iscell(file)
    clear_status(handles, lang); % Clear previous status
else
    disp_error(handles, 60, 15, lang);
    return;
end

% Set pointer
set(handles.root, 'pointer', 'watch');

% Necessary files, 1: NS, 2: EW, 3: Z
files = cell(3, 1);

%% Save each file to an cell structure
for f = 1:totalfiles
    ft = get_type_file(file{f});
    if ft
        files{ft} = file{f};
    end
end

%% Check that all files are loaded
for k = 1:3
    % If a file is not loaded then function stops
    if isempty(files{k})
        disp_error(handles, 10, 15, lang);
        return;
    end
end

%% Files are loaded
try
    data_ns = load(strcat(folder, files{1}));
    data_ew = load(strcat(folder, files{2}));
    data_z = load(strcat(folder, files{3}));
catch
    disp_error(handles, 12, 15, lang);
    return;
end

%% Store acceleration and time data from files
ns_acc = data_ns(:, 2);
ew_acc = data_ew(:, 2);
z_acc = data_z(:, 2);

ns_t = data_ns(:, 1);
ew_t = data_ew(:, 1);
z_t = data_z(:, 1);

%% Checks that all files have the same size of elements
if length(ns_acc) ~= length(ew_acc) && length(ew_acc) ~= length(z_acc)
    disp_error(handles, 13, 14, lang);
    return;
end

%% Calculate frecuency and dt
dt = ns_t(2) - ns_t(1);
f = 1 / dt; % Sampling rate

%% Acceleration data is plotted
axes(handles.plot_ns);
plot(ns_t, ns_acc, STYLE_ACCELERATION_PLOT);
hold on;
xlim([0, max(ns_t)]);
yaxis_linspace(5);
xaxis_linspace(6);
grid on;
axes(handles.plot_ew);
plot(ew_t, ew_acc, STYLE_ACCELERATION_PLOT);
hold on;
xlim([0, max(ew_t)]);
yaxis_linspace(5);
xaxis_linspace(6);
grid on;
axes(handles.plot_z);
plot(z_t, z_acc, STYLE_ACCELERATION_PLOT);
hold on;
xlim([0, max(z_t)]);
yaxis_linspace(5);
xaxis_linspace(6);
grid on;

%% Stransform / Pick FFT region + windows
if istrfm(NUM_METHOD)
    M = [z_acc, ns_acc, ew_acc];
    [m, ~] = size(M);
    
    % Request window time
    data = inputdlg({sprintf(lang{63}, max(ns_t))}, lang{62}, [1, 50], ...
        {num2str(min(STRANSFORM_DEFAULT_WINDOW_WIDTH, round(max(ns_t))))});
    try
        T = data{1};
    catch
        disp_error(handles, 59, 11, lang);
        return;
    end
    try
        T = str2double(T);
    catch
        disp_error(handles, 22, 11, lang);
        return;
    end
    if T > max(ns_t)
        disp_error(handles, 67, 11, lang);
        return;
    end
    fi = ceil(STRANSFORM_F_MIN*T);
    ff = ceil(STRANSFORM_F_MAX*T);
    
    % Number of windows
    totalitr = fix(m/(f * T));
    if totalitr <= 1
        totalitr = 1;
        M = [M; zeros(f*T-size(M, 1), 3)];
    end
    
    % Create frecuency array
    freq_h = STRANSFORM_F_MIN:1 / T:STRANSFORM_F_MAX;
    t_len_h = length(freq_h);
    
    % Plot time limits
    lim1 = 0;
    lim2fix = max(1:NUM_METHOD:T*f*totalitr) / f;
else
    % Baseline correction
    ns_acc = detrend(ns_acc, 0);
    ew_acc = detrend(ew_acc, 0);
    z_acc = detrend(z_acc, 0);
    
    % Request window limits
    fig_obj = figure('Name', lang{7}, 'NumberTitle', 'off');
    plot(ns_t, ns_acc./G_VALUE, 'k', 'DisplayName', 'N-S');
    hold on;
    plot(ns_t, ew_acc./G_VALUE, 'r', 'DisplayName', 'E-W');
    plot(ns_t, z_acc./G_VALUE, 'b', 'DisplayName', 'Z');
    alpha(.7);
    xaxis_linspace(10);
    xlim([0, max(ns_t)]);
    xlabel(lang{17});
    ylabel(lang{18});
    legend('show');
    grid on;
    movegui(fig_obj, 'center');
    try
        data_region = ginput(1);
        lim1 = data_region(1, 1);
        plot([lim1, lim1], get(gca, 'ylim'), 'k--', 'displayname', 'Límite inferior');
        data_region = ginput(1);
        lim2 = data_region(1, 1);
        limits = [lim1, lim2];
        lim1 = min(limits);
        lim2 = max(limits);
    catch
        disp_error(handles, 16, 11, lang);
        return;
    end
    if lim1 == lim2
        disp_error(handles, 24, 11, lang);
        return;
    end
    close(fig_obj);
    
    % Ask time and dt of windows
    wsize = min(lim2-lim1, WINDOW_SIZE);
    data = inputdlg({sprintf(lang{21}, lim2-lim1), lang{20}}, lang{19}, ...
        [1, 50; 1, 50], {num2str(round(wsize)), num2str(WINDOW_MOVE)});
    try
        wtime = data{1};
        wdt = data{2};
    catch
        disp_error(handles, 59, 11, lang);
        return;
    end
    
    % Check that wtime and wdt are numbers
    if strcmp(wtime, 'i') || strcmp(wdt, 'i')
        disp_error(handles, 22, 23, lang);
        return;
    end
    
    % Convert to number
    try
        wtime = str2double(wtime);
        wdt = str2double(wdt);
    catch
        disp_error(handles, 22, 23, lang);
        return;
    end
    
    % Window array lengths
    t_len = floor(wtime/dt);
    t_len_h = floor(t_len/2);
    
    % Create tuckey (5%)
    tuckey = tukeywin(t_len, 0.05);
    
    % Create frecuency array
    freq_arr = 0:f / t_len:f - 1 / t_len;
    freq_h = freq_arr(1:t_len_h); % Half of frequency
    
    % Calculate total iterations
    totalitr = 1;
    k = 1;
    while true
        if k * wdt +wtime + lim1 <= lim2
            totalitr = totalitr + 1;
            k = k + 1;
        else
            break;
        end
    end
    process_timer(handles, lang, 0.001);
    lim2fix = lim1 + (totalitr - 1) * wdt + wtime;
end

% Plot limits on accel plots
axes(handles.plot_ns);
draw_vx_line(lim1, STYLE_REGION_ACCEL_FIX);
draw_vx_line(lim2fix, STYLE_REGION_ACCEL_FIX);
axes(handles.plot_ew);
draw_vx_line(lim1, STYLE_REGION_ACCEL_FIX);
draw_vx_line(lim2fix, STYLE_REGION_ACCEL_FIX);
axes(handles.plot_z);
draw_vx_line(lim1, STYLE_REGION_ACCEL_FIX);
draw_vx_line(lim2fix, STYLE_REGION_ACCEL_FIX);

%% Sum of sh/sv to calculate mean
sum_shsv = zeros(t_len_h, 1);
max_freqs = zeros(totalitr, 1);
max_shsv = zeros(totalitr, 1);
min_shsv = zeros(totalitr, 1);
tic;
re_accel = cell(6); % Lines of region plotted on acceleration plots

%% Start iteration process
for itr = 1:totalitr
    
    % Select iteration time limits
    if istrfm(NUM_METHOD)
        int = T * f * (itr - 1) + 1:NUM_METHOD:T * f * itr;
        ilim1 = min(int) / f;
        ilim2 = max(int) / f;
    else
        ilim1 = wdt * (itr - 1) + lim1;
        ilim2 = ilim1 + wtime;
    end
    
    % Plot window on accelration plots
    if SHOW_REGION_ON_ACCELERATION
        axes(handles.plot_ns);
        if itr > 1
            delete(re_accel{1});
            delete(re_accel{2});
        end
        re_accel{1} = draw_vx_line(ilim1, STYLE_REGION_ACCEL);
        re_accel{2} = draw_vx_line(ilim2, STYLE_REGION_ACCEL);
        axes(handles.plot_ew);
        if itr > 1
            delete(re_accel{3});
            delete(re_accel{4});
        end
        re_accel{3} = draw_vx_line(ilim1, STYLE_REGION_ACCEL);
        re_accel{4} = draw_vx_line(ilim2, STYLE_REGION_ACCEL);
        axes(handles.plot_z);
        if itr > 1
            delete(re_accel{5});
            delete(re_accel{6});
        end
        re_accel{5} = draw_vx_line(ilim1, STYLE_REGION_ACCEL);
        re_accel{6} = draw_vx_line(ilim2, STYLE_REGION_ACCEL);
    end
    
    % Stockwell Transform (S-transform)
    if istrfm(NUM_METHOD)
        Mv = detrend(M(int, 1));
        Mn = detrend(M(int, 2));
        Me = detrend(M(int, 3));
        hvw = funhv(Mv, Mn, Me, fi, ff);
        
        if itr == 1
            hv = zeros(size(hvw));
        end
        
        % Geometric mean
        hv = hv + log(hvw);
        
        mean_shsv = exp(hv'./fix(m/(f * T)));
        [~, n_hv] = size(mean_shsv);
        
        % Get sh/sv mean or median
        if strcmp(STRANSFORM_TYPE, 'MEAN')
            pp = zeros(n_hv, 3);
            for j = 1:n_hv
                vt = mean_shsv(:, j);
                pp(j, 1) = mean(vt);
                pp(j, 2) = std(vt(vt > pp(j, 1)));
                pp(j, 3) = std(vt(vt < pp(j, 1)));
            end
            mean_shsv = pp(:, 1);
        elseif strcmp(STRANSFORM_TYPE, 'MEDIAN')
            Q = zeros(n_hv, 9);
            for j = 1:n_hv
                vt = mean_shsv(:, j);
                Q(j, 1) = prctile(vt, 10);
                Q(j, 2) = prctile(vt, 20);
                Q(j, 3) = prctile(vt, 40);
                Q(j, 4) = prctile(vt, 50);
                Q(j, 5) = prctile(vt, 60);
                Q(j, 6) = prctile(vt, 80);
                Q(j, 7) = prctile(vt, 90);
                Q(j, 8) = prctile(vt, 0);
                Q(j, 9) = prctile(vt, 100);
            end
            mean_shsv = Q(:, 4);
        else
            disp_error(handles, 64, 11, lang);
            return;
        end
    else
        % Create new arrays
        ns_itr = zeros(t_len, 1);
        ew_itr = zeros(t_len, 1);
        z_itr = zeros(t_len, 1);
        
        j = 1; % Index to store values
        for i = 1:length(ns_t)
            if ilim2 >= ns_t(i) && ns_t(i) >= ilim1
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
        fft_ns = ns_fft_itr(1:t_len_h);
        fft_ew = ew_fft_itr(1:t_len_h);
        fft_z = z_fft_itr(1:t_len_h);
        
        % Apply smooth
        fft_ns = smooth_spectra(fft_ns, freq_h, NUM_METHOD);
        fft_ew = smooth_spectra(fft_ew, freq_h, NUM_METHOD);
        fft_z = smooth_spectra(fft_z, freq_h, NUM_METHOD);
        try
            fft_ns = smooth_spectra(fft_ns, freq_h, NUM_METHOD);
            fft_ew = smooth_spectra(fft_ew, freq_h, NUM_METHOD);
            fft_z = smooth_spectra(fft_z, freq_h, NUM_METHOD);
        catch
            disp_error(handles, 61, 11, lang);
            return;
        end
        
        % Calculate SH
        sh = sqrt((fft_ns.^2 + fft_ew.^2)./2);
        sh_sv = sh ./ fft_z;
        
        % Delete NaN
        sh_sv(isnan(sh_sv)) = 0;
        
        % Add sh/sv to mean
        sum_shsv = sum_shsv + sh_sv;
        
        % Mean sh/sv
        mean_shsv = sum_shsv ./ itr;
    end
    
    % Calculate maximum/minimum frecuency and sh/sv
    svsh_max = 0;
    svsh_min = inf;
    maxf = 0;
    for j = 1:length(freq_h)
        if mean_shsv(j) > svsh_max && freq_h(j) > MIN_F_SHSV
            svsh_max = mean_shsv(j);
            maxf = freq_h(j);
        end
        if mean_shsv(j) < svsh_min && freq_h(j) > MIN_F_SHSV && mean_shsv(j) > 0
            svsh_min = mean_shsv(j);
        end
        if freq_h(j) > MAX_F_SHSV
            break;
        end
    end
    
    % Set MAX F and MAX/MIN SH/SV
    max_freqs(itr) = maxf;
    max_shsv(itr) = svsh_max;
    min_shsv(itr) = svsh_min;
    
    % Plot mean
    axes(handles.plot_avg_shsv); %#ok<*LAXES>
    semilogx(freq_h, mean_shsv, STYLE_AVERAGE_SHSV);
    xlim([MIN_F_SHSV, MAX_F_SHSV]);
    lims = get(gca, 'ylim');
    ylim([0, lims(2)]);
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
    xlim([1, max(itr, 2)]);
    lims = get(gca, 'ylim');
    ylim([0, lims(2) * 1.2]);
    yaxis_linspace(5);
    hold off;
    grid on;
    
    % Plot MAX SH/SV
    axes(handles.plot_maxshsv);
    plot(1:1:itr, max_shsv(1:itr), STYLE_MAX_SHSV);
    xlim([1, max(itr, 2)]);
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

%% Show final results
if SHOW_ITR_MAXSHSV
    if strcmp(PLOT_X_VAR, 'FREQ')
        strtextmsg = 'Hz | Amp=';
        strxlabel = lang{31};
    elseif strcmp(PLOT_X_VAR, 'PERIOD')
        freq_h = (freq_h.^-1) .* (2 * pi);
        [~, n2] = max(mean_shsv);
        max_freqs(end) = freq_h(n2);
        strtextmsg = 's | Amp=';
        strxlabel = lang{69};
    else
        disp_error(handles, 68, 11, lang);
        return;
    end
    figurename = strrep(file{1}, '_E', '');
    figurename = strrep(figurename, '_Z', '');
    figurename = strrep(figurename, '_W', '');
    figurename = strrep(figurename, '.txt', '');
    fig_obj = figure('Name', figurename, 'NumberTitle', 'off');
    movegui(fig_obj, 'center');
    setappdata(handles.root, 'figureid1', fig_obj);
    hold on;
    if istrfm(NUM_METHOD) && DISPLAY_VAR_PERCENTILS_STRANSFORM
        if strcmp(STRANSFORM_TYPE, 'MEAN')
            fill([freq_h, fliplr(freq_h)], [(pp(:, 1) + pp(:, 2))', fliplr((pp(:, 1) - pp(:, 3))')], ...
                [0.7937, 0.7937, 0.7937], 'LineStyle', 'none');
            title(lang{65});
        elseif strcmp(STRANSFORM_TYPE, 'MEDIAN')
            fill([freq_h, fliplr(freq_h)], [Q(:, 8)', fliplr(Q(:, 9)')], [0.9365, 0.9365, 0.9365], 'LineStyle', 'none');
            fill([freq_h, fliplr(freq_h)], [Q(:, 7)', fliplr(Q(:, 1)')], [0.8889, 0.8889, 0.8889], 'LineStyle', 'none');
            fill([freq_h, fliplr(freq_h)], [Q(:, 6)', fliplr(Q(:, 2)')], [0.7937, 0.7937, 0.7937], 'LineStyle', 'none');
            fill([freq_h, fliplr(freq_h)], [Q(:, 5)', fliplr(Q(:, 3)')], [0.6984, 0.6984, 0.6984], 'LineStyle', 'none');
            title(lang{30});
        end
    else
        title(lang{30});
    end
    plot(freq_h, mean_shsv, STYLE_SHSV_F);
    grid on;
    set(gca, 'xscale', 'log', 'xlim', [min(freq_h), max(freq_h)], 'ylim', ...
        [SHSV_YLIM_MIN_CF, SHSV_YLIM_MAX_CF], 'box', 'on');
    draw_vx_line(max_freqs(end), STYLE_SHSV_MAXF);
    [~, n2] = max(mean_shsv);
    if SHOW_RESULTS_FSHSV_PLOT
        text(max_freqs(end), 9, ['Fo=', num2str(freq_h(n2)), strtextmsg, num2str(round(max(mean_shsv)*100)/100)], ...
            'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'FontSize', 9, 'EdgeColor', 'k', ...
            'BackgroundColor', [1, 1, 1]);
    end
    xlabel(strxlabel);
    ylabel(lang{32});
end

%% Message to user
if SHOW_ITR_DIALOG
    if strcmp(PLOT_X_VAR, 'FREQ')
        msgmaxfreqs = lang{25};
    elseif strcmp(PLOT_X_VAR, 'PERIOD')
        msgmaxfreqs = lang{70};
    else
        disp_error(handles, 68, 11, lang);
        return;
    end
    resultmsg = msgbox({sprintf(msgmaxfreqs, max_freqs(end)); sprintf(lang{26}, ...
        max_shsv(end)); ''; sprintf(lang{27}, totalitr); sprintf(lang{28}, exec_time)}, ...
        lang{29}, 'help');
    setappdata(handles.root, 'resultmsg', resultmsg);
    movegui(resultmsg, 'center');
end

end