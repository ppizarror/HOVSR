function new_spectrum = smooth_spectra(spectrum, freq, stype)
% SMOOTH SPECTRA
% Smooth of spectrum
%
% PARAMETERS:
%   fft:    Spectrum to apply smooth
%   freq:   Frecuencies
%   stype:  Type of the smooth
%           (1) S-transform - All data
%           (2) S-transform - Window med point
%           (3) Konno-Ohmachi with no abs value
%           (4) Konno-Ohmachi with abs value
%           (5) Konno-Ohmachi with no abs value + normalize
%           (6) Konno-Ohmachi with abs value + normalize
%           (7) Smooth function with no abs value
%           (8) Smooth function with abs value
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

%% Constants
constants;
KONNO_BANWIDTH = 30;
SMOOTH_SPAN = 0.1;
SMOOTH_TYPE = 'loess';

%% Switch smooth options
switch stype
    
    % Stockwell Transform (S-Transform) - window all data
    case STRANSFORM_ALL
        new_spectrum = spectrum;
    
    % Stockwell Transform (S-Transform) - window med data
    case STRANSFORM_MED
        new_spectrum = spectrum;
    
    % Konno-Ohmachi - no abs
    case 3
        fc = freq(floor(length(freq)/2)+1); % Central frequency
        konno = konno_ohmachi(freq, fc, KONNO_BANWIDTH, false)';
        new_spectrum = spectrum .* konno;
        
    % Konno-Ohmachi + abs
    case 4
        fc = freq(floor(length(freq)/2)+1); % Central frequency
        konno = konno_ohmachi(freq, fc, KONNO_BANWIDTH, false)';
        new_spectrum = spectrum .* konno;
        
        % Apply abs value
        new_spectrum = abs(new_spectrum);
        
    % Konno-Ohmachi - no abs + normalize
    case 5
        fc = freq(floor(length(freq)/2)+1);
        konno = konno_ohmachi(freq, fc, KONNO_BANWIDTH, true)';
        new_spectrum = spectrum .* konno;
        
    % Konno-Ohmachi + abs + normalize
    case 6
        fc = freq(floor(length(freq)/2)+1);
        konno = konno_ohmachi(freq, fc, KONNO_BANWIDTH, true)';
        new_spectrum = spectrum .* konno;
        
        % Apply abs value
        new_spectrum = abs(new_spectrum);
        
    % Uses smooth function - no abs
    case 7
        new_spectrum = smooth(freq, spectrum, SMOOTH_SPAN, SMOOTH_TYPE);
        
    % Uses smooth function + abs
    case 8
        new_spectrum = smooth(freq, abs(spectrum), SMOOTH_SPAN, SMOOTH_TYPE);
		
	% Mean 5-point
	case 9
		new_spectrum = smooth(abs(spectrum));
        
    otherwise
        error('Smoothing type does not exist.');
end

end

