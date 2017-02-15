function start_process(handles)
% Esta función empieza el proceso desde que se eligen archivos

%% Selecciona archivo
[file, folder] = uigetfile({'*.txt', 'Archivo de aceleración (*.txt)'}, 'Seleccione un archivo');
filenames = strsplit(file, '_');
file_id = filenames{3}; % Indicador del archivo
file_t = get_type_file(file, file_id);

files = cell(3, 1); % Archivos necesarios, 1: NS, 2: EW, 3: Z
files{file_t}=file;

%% Se escanea la carpeta para buscar los demas archivos necesario
folder_files = dir(folder);
for f=1:length(folder_files)
    ft = get_type_file(folder_files(f).name, file_id);
    if ft
        files{ft}=folder_files(f).name;
    end
end

%% Chequea si están todos los archivos
for k=1:3
    % Si no se han cargado todos los archivos
    if isempty(files{k})
        errordlg('Asegúrese que en la misma carpeta existan los archivos N-S (_N), E-W (_E) y Z (_Z).', 'Error');
        return
    end
end

%% Se cargan los archivos
try
    data_ns= load(strcat(folder, files{1}));
    data_ew= load(strcat(folder, files{2}));
    data_z= load(strcat(folder, files{3}));
catch
    errordlg('Ocurrió un error al cargar los archivos.', 'Error');
    return
end

%% Se cargan las columnas de tiempo y aceleración
ns_acc = data_ns(:, 2);
ew_acc = data_ew(:, 2);
z_acc = data_z(:, 2);

ns_t = data_ns(:, 1);
ew_t = data_ew(:, 1);
z_t = data_z(:, 1);

%% Corrección por línea base
ns_acc = detrend(ns_acc);
ew_acc = detrend(ew_acc);
z_acc = detrend(z_acc);

%% Se plotean los archivos
axes(handles.plot_ns);
plot(ns_t, ns_acc, 'k');
xlim([0 max(ns_t)]);
grid on;
axes(handles.plot_ew);
plot(ew_t, ew_acc, 'k');
xlim([0 max(ew_t)]);
grid on;
axes(handles.plot_z);
plot(z_t, z_acc, 'k');
xlim([0 max(z_t)]);
grid on;

%% Se hace smoothing tuckey

end

