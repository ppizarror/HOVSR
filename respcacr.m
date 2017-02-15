function [x, v, a] = respcacr(m, T, b, P, Fs, xo, vo)
% [x,v,a] = respcacr(m,T,b,P,Fs,xo,vo)
% [x,v,a] = respcacr([-]m,k,c,P,Fs,xo,vo)
%
% Genera respuesta de un oscilador linear estable paso a paso
% metodo de aceleracion constante. SUPONE 1 GDL.
%
% Metodo incondicionalmente estable autoiniciante. Por precision
% se recomienda que Fs > 10/T. OJO USA LTILR: ES MAS RAPIDO
%
% Con propiedades b y w a  una  senal  de excitacion P.
% Parametros de entrada
%   m:      masa del sistema
%   b:      razon amortigumiento critico
%   c:      amortigumiento critico
%   T:      periodo no amortiguado del oscilador sec
%   k:      rigidez del oscilador
%   P:      registro de excitacion (-m*vg si es ac.)
%   Fs:     frecuencia muestreo en registro aceleracion
%   xo:     desplazamiento inicial
%   vo:     velocidad inicial
%   x:      respuesta en desplazamiento relativo
%   v:      respuesta en velocidad relativa
%   at:     respuesta en aceleracion total SOLO par P=m*vg
%   a:      respuesta en aceleracion relativa

%% Se crea la ecuación de un oscilador armónico de 1 grado de libertad
np = length(P);
dt = 1 / Fs;
dt2 = dt * dt;
if m > 0
    w = 2 * pi / T;
    k = m * w * w;
    c = 2 * m * w * b;
else
    k = T;
    c = b;
    m = abs(m);
end

% Ecuación de rigidez, k*
kk = (4*m) / dt2 + 2 / dt * c + k;

% Calcula la inversa
ikk = inv(kk);

ao = (P(1) - c * vo - k * xo) / m;  % Expresión de fuerza
P = [P(2:np); P(np)]; % Elimina el primer elemento y repite el último

dt24 = 4 / dt2;
km = ikk * m; %#ok<*MINV>
mdt24 = km * 4 / dt2;
dt14 = 4 / dt;
mdt14 = ikk * m * 4 / dt;
dt12 = 2 / dt;
kc = ikk * c;
cdt12 = kc * 2 / dt;

AA= [mdt24+cdt12            mdt14+ikk*c             km;
    dt12*(mdt24+cdt12)-dt12 dt12*(mdt14+ikk*c)-1    dt12*km;
    dt24*(mdt24+cdt12)-dt24 dt24*(mdt14+ikk*c)-dt14 dt24*km-1];
BB= [ikk                    ikk*dt12                ikk*dt24].';

% Computa el tiempo de respuesta de AAx[t] + BB*P[t]
xx = ltitr(AA, BB, P, [xo vo ao].');
a = [xx(:, 3)]; %#ok<*NBRAK>
v = [xx(:, 2)];
x = [xx(:, 1)];