function [X,Y] = hatch_coordinates( xlim , ylim , xstep , ystep , merge )
% Return coordinates for plotting a hatch pattern.
% The angle of the lines can be adjusted by varying the ratio xstep/ystep
% Retrieved from http://stackoverflow.com/questions/29949205/hatch-a-plot-in-matlab

%% // set default options
if nargin < 3 ; xstep = 1     ; end
if nargin < 4 ; ystep = xstep ; end
if nargin < 5 ; merge = true  ; end

%% // define base grid
xpos = xlim(1):xstep:xlim(2) ; nx = numel(xpos) ;
ypos = ylim(1):ystep:ylim(2) ; ny = numel(ypos) ;

%% // Create the coordinates
nanline = NaN*ones(1,nx+ny-3) ;
X = [ [ xpos(1)*ones(1,ny-2) xpos(1:end-1) ] ; ...
      [ xpos(2:end) xpos(end)*ones(1,ny-2) ] ; ...
      nanline ] ;
Y = [ [ypos(end-1:-1:1) zeros(1,nx-2)]  ; ...
      [ypos(end)*ones(1,nx-1) ypos(end-1:-1:2)] ; ...
      nanline ] ;

%% // merge if asked too
if merge
    X = X(:) ;
    Y = Y(:) ;
end