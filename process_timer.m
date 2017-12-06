function process_timer(handles, lang, itotal)
% PROCESS TIMER
% This function sets estimated time of the process.
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

if itotal == 0
    set(handles.processing_text, 'String', '');
else
    if itotal ~= 1
        set(handles.processing_text, 'String', sprintf(lang{6}, itotal*100));
    else
        set(handles.processing_text, 'String', lang{52});
    end
end

% Select status plot
h = handles.status_plot;
axes(h);

% Plot bar
axis([0, 1, 0, 1]);
if itotal == 0
    patch([0, 1, 1, 0], [0, 0, 1, 1], [255, 255, 255]./255);
else
    patch([0, itotal, itotal, 0], [0, 0, 1, 1], [29, 119, 29]./255);
end

end