% CONFIG
% HOVSR configuration file.
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

%% App config
APP_SOUNDS = true;
LANGUAGE = 2; % 1: English, 2: Spanish

%% Transform/Smooth numerical method type
% (1) Stockwell Transform (S-transform), window with all data
% (2) Stockwell Transform (S-transform), window with med point data
% (3) FFT + Konno-Ohmachi with no abs value
% (4) FFT + Konno-Ohmachi with abs value
% (5) FFT + Konno-Ohmachi with no abs value + normalize
% (6) FFT + Konno-Ohmachi with abs value + normalize
% (7) FFT + Smooth function with no abs value
% (8) FFT + Smooth function with abs value
% (9) FFT + Mean 5 point
NUM_METHOD = 2;

%% S-Transform MEAN/MEDIAN
STRANSFORM_TYPE = 'MEDIAN';

%% S-Transform min/max frequencies
STRANSFORM_F_MAX = 10;
STRANSFORM_F_MIN = 0.1;

%% S-Transform default window width (s)
STRANSFORM_DEFAULT_WINDOW_WIDTH = 30;

%% Plot configuration
DISPLAY_VAR_PERCENTILS_STRANSFORM = false; % Show variance, percentile on stransform plots
MAX_F_SHSV = 10; % Max frequency on result plots
MIN_F_SHSV = 0.1; % Min frequency on result plots
SHOW_MAX_F_ON_AVERAGE_SHSV = true; % Show maximum f on AVERAGE_SHSV
SHOW_REGION_ON_ACCELERATION = true; % Show iteration limits on timeseries plots
SHOW_RESULTS_FSHSV_PLOT = true; % Show text with results of f-sh/sv
SHSV_YLIM_MAX_CF = 10; % Max sh/sv limit on plots
SHSV_YLIM_MIN_CF = 0; % Min sh/sv limit on plots
STYLE_ACCELERATION_PLOT = 'k';
STYLE_AVERAGE_SHSV = 'k';
STYLE_MAX_F = 'k-';
STYLE_MAX_F_ON_AVERAGE = 'r--';
STYLE_MAX_SHSV = 'k-';
STYLE_REGION_ACCEL = 'k--';
STYLE_REGION_ACCEL_FIX = 'k';
STYLE_SHSV_F = 'k-';
STYLE_SHSV_MAXF = 'r--';

%% Iteration results
SHOW_ITR_DIALOG = true; % Show info dialog after iteration finishes
SHOW_ITR_MAXSHSV = true; % Show result plot after iteration finishes