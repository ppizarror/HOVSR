function [hv, hve, hvn] = funhv(Mv, Mn, Me, fi, ff)
% HV FUNCTION
% Calculates hv from V (Vertical), N (North-South) and E (East-West)
% acceleration timeseries.
% Also returns hve = E/V and hvn = N/V.
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

% Stockwell Transform
stV = st(Mv', fi, ff);
stN = st(Mn', fi, ff);
stE = st(Me', fi, ff);

[m, n] = size(stV);
hv = zeros(m, n);
hve = zeros(m, n);
hvn = zeros(m, n);

% Calculate H/V
for j = 1:n
    for i = 1:m
        hv(i, j) = sqrt((abs(stN(i, j))^2 + abs(stE(i, j)^2))/2) / abs(stV(i, j));
        hve(i, j) = abs(stE(i, j))/ abs(stV(i, j));
        hvn(i, j) = abs(stN(i, j))/ abs(stV(i, j));
    end
end

end