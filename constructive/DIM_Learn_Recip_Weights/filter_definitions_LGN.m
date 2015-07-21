function [LoG]=filter_definitions_LGN(sigma,weightScale)
if nargin<1, sigma=1.5; end

%Laplacian of Gaussians
LoG=-fspecial('log',odd(9*sigma),sigma);
%To avoid using Image Processing toolbox try:
%LoG=gauss2D(sigma-0.0001,0,1,1,odd(9*sigma))-gauss2D(sigma+0.0001,0,1,1,odd(9*sigma));

%use single precision for speed
LoG=single(LoG);

%normalise weights
tmp=LoG;
tmp(find(tmp<0))=0;
LoG=LoG./sum(sum(tmp));

