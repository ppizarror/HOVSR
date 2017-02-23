function clear_status(handles, lang)
% This function clear status of app.
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

% Reset graphs
axes(handles.plot_ns);
cla reset;
yaxis_linspace(5);
set(gca,'fontsize', 10);
grid on;
axes(handles.plot_ew);
cla reset;
yaxis_linspace(5);
grid on;
axes(handles.plot_z);
cla reset;
yaxis_linspace(5);
grid on;
axes(handles.plot_avg_shsv);
cla reset;
yaxis_linspace(5);
grid on;
axes(handles.plot_maxf);
cla reset;
yaxis_linspace(5);
grid on;
axes(handles.plot_maxshsv);
cla reset;
yaxis_linspace(5);
grid on;

% Closes generated figures
try
    close(getappdata(handles.root, 'figureid1'))
catch
end

% Delete timer
process_timer(handles, lang, 0);

% Disable export button
set(handles.menu_export_results, 'Enable', 'off');
set(handles.button_exportresults, 'Enable', 'off');

end