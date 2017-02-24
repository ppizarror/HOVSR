function ff = konno_ohmachi(f, fc, b, normalize)
% KONNO OHMACHI
% Konno and Ohmachi (1998) [1] smoothing.
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
%
% [1]: Konno, K. and Omachi, T., 1998, Bull. Seism. Soc. Am., 88, 228-241.

log10f_b = b * log10(f./fc);
ff = (sin(log10f_b) ./ (log10f_b)) .^ 4;

if normalize
    ff = ff ./ sum(ff);
end

end

