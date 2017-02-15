function [t]=max_t(columna, Fs)
% Retorna el tiempo asociado a la máxima aceleración calculada por el
% oscilador para un tiempo y una razón de amortiguamiento.

m=size(columna);
a=0;
for i=1:m
    % Almacena la máxima aceleración y guarda el tiempo asociado
    if abs(a) < abs(columna(i))
        a = abs(columna(i));
        t = i/Fs;
    end
end