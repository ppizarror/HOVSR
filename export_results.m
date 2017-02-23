function export_results(handles, lang)
% EXPORT RESULTS
% Export SH/SV vs f data to a file.
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

%% Get results status
if ~ getappdata(handles.root, 'results')
    disp_error(handles, 48, 49, lang);
    return
end

%% Request filename
lastfolder = getappdata(handles.root, 'lastsave_folder');
if ~strcmp(lastfolder, '')
    [file, folder] = uiputfile({'*.txt', lang{46}}, lang{47}, lastfolder);
else
    [file, folder] = uiputfile({'*.txt', lang{46}}, lang{47});
end

%% If file is not valid
if file==0
    return
    
% Save last folder
else
    setappdata(handles.root, 'lastsave_folder', folder);
end

%% Create file
try
    fl = strcat(folder, file);
    new_file = fopen(fl, 'wt');
    fprintf(new_file, 'f (Hz)\t\tSH/SV\n');
    
    % Get data
    shsv = getappdata(handles.root, 'results_shsv');
    f = getappdata(handles.root, 'results_f');

    % Save data
    for j=1:length(f)
        fprintf(new_file, '%f\t%f\n', f(j), shsv(j));
    end
    fclose(new_file);
    
    % Show message
    msgbox(lang{51}, lang{52});
    
catch
    disp_error(handles, 50, 49, lang);
    return
end

end