function s = get_type_file(filename)
% GET TYPE FILE
% Returns file type (NS, EW, Z).
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

% Import constants
constants;

try
    w = strsplit(filename, '_');
    
    for i = 1:length(w)
        if strcmp(w(i), 'N')
            s = 1;
            return
        elseif strcmp(w(i), 'E')
            s = 2;
            return
        elseif strcmp(w(i), 'Z')
            s = 3;
            return
        end
    end
catch
end
s = 0;

end

