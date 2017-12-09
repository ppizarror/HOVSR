function [hv, hve, hvn] = funakamura(t_len, t_len_h, freq_h, ns_acc, ew_acc, z_acc, tuckey, ns_t, ilim1, ilim2)
% FUNAKAMURA
% Nakamura spectral method, uses fft + smoothing to obtain H/V.
% Also returns hve = E/V and hvn = N/V.
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

% Load constants and configuration
config;
constants;

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

[m, n] = size(fft_z);
hv = zeros(m, n);
hve = zeros(m, n);
hvn = zeros(m, n);

% Calculate H/V
for j = 1:n
    for i = 1:m
        hv(i, j) = sqrt((abs(fft_ns(i, j))^2 + abs(fft_ew(i, j)^2))/2) / abs(fft_z(i, j));
        hve(i, j) = abs(fft_ew(i, j)) / abs(fft_z(i, j));
        hvn(i, j) = abs(fft_ns(i, j)) / abs(fft_z(i, j));
    end
end

end