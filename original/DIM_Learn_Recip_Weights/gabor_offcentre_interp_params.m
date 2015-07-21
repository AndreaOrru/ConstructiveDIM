function g=gabor_offcentre_interp_params(params,pxsize)
g=gabor_offcentre(params(1),params(2),params(3),params(4),...
				  params(5),params(6),params(7),params(8),pxsize);  

function gb=gabor_offcentre(x0,y0,sigmaX,sigmaY,orient,freq,phase,amp,pxsize)
%function gb=gabor_offcentre(x0,y0,sigmaX,sigmaY,orient,freq,phase,amp,pxsize)
%
% This function produces a numerical approximation to 2D Gabor function.
% Parameters:
% x0     = x-coordinate of the centre of the Gabor (pixels)
% y0     = y-coordinate of the centre of the Gabor (pixels)
% sigmaX = standard deviation of Gaussian envelope width (pixels)
% sigmaY = standard deviation of Gaussian envelope length (pixels)
% orient = orientation of the Gabor clockwise from the vertical (degrees)
% freq   = the frequency of the sinusoid (cycles/pixel)
% phase  = the phase of the sinusoid (degrees)
% amp    = amplitude of the Gabor
% pxsize = the size of the filter (pixesls). 

[x y]=meshgrid(-fix(pxsize/2):fix(pxsize/2),fix(-pxsize/2):fix(pxsize/2));
x=x(1:pxsize,1:pxsize);
y=y(1:pxsize,1:pxsize);

% Rotation 
orient=orient*pi/180;
x_theta=(x-x0)*cos(orient)+(y-y0)*sin(orient);
y_theta=-(x-x0)*sin(orient)+(y-y0)*cos(orient);

phase=phase*pi/180;

gb=amp.*(exp(-0.5.*( (x_theta./sigmaX).^2 + (y_theta./sigmaY).^2 )) ...
   .* cos(2*pi.*freq.*x_theta+phase));

