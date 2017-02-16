function [t, to] = time2(a, Fs)
% t=time(a, Fs)
% Genera vector de tiempo.
% t :   Vector de tiempo de longitud length(a)
%       Si <a> es escalar genera vector de longitud <a>
% Fs:   Frecuencia de muestreo
%

if length(a) == 1
    t = (0:a - 1) / Fs;
else
    t = (0:(length(a) - 1)) / Fs;
end

t = t';
b = length(a) - 9;
to = (length(a) - 1) / Fs;
for i = b:length(a)
    if or(a(i) > 0, a(i) < 0)
        to = (i - 1) / Fs;
    end
end