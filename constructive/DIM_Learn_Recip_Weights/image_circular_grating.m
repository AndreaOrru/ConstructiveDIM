function I=image_circular_grating(csize,vsize,wavel,angle,phase,cont)
% csize  = the diameter of the centre patch (pixels)
% vsize  = the width of the blank area around the centre
% wavel  = the wavelength of the sin wave (pixels)
% angle = angle of the grating
% phase = the phase of the central patch
% cont = contrast of central patch

freq=2*pi./wavel;
angle=-angle*pi/180;
phase=phase*pi/180;

%define image size
sz=fix(csize+2*vsize);
if mod(sz,2)==0, sz=sz+1;end %image has odd dimension

%define mesh on which to draw sinusoids
[x y]=meshgrid(-fix(sz/2):fix(sz/2),fix(-sz/2):fix(sz/2));
yg=-x*sin(angle)+y*cos(angle);

%make sinusoids with values ranging from 0 to 1 (i.e. contrast is positive)
grating=0.5+0.5.*cont.*cos(freq*yg+phase);

%define radius from centre point
radius=sqrt(x.^2+y.^2);

%put togeter image from components
I=zeros(sz)+0.5;
I(find(radius<csize/2))=grating(find(radius<csize/2));

