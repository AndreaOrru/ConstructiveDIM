function I=image_cross_orientation_sine(sz,wavelc,wavelm,angle,diff,phasec,phasem,contc,contm)
% sz  = the diameter of the image
% wavelc  = the wavelength of the principal grating (pixels)
% wavelm  = the wavelength of the mask grating (pixels)
% angle = angle of the principal grating
% diff = angle between the gratings
% phasec = the phase of the principal grating
% phasem = the phase of the mask grating
% contc = contrast of the principal grating
% contm = contrast of the mask grating

freqc=2*pi./wavelc;
freqm=2*pi./wavelm;
angle=-angle*pi/180;
diff=-diff*pi/180;
phasec=phasec*pi/180;
phasem=phasem*pi/180;

%define image size
if mod(sz,2)==0, sz=sz+1;end %image has odd dimension
I=zeros(sz);

%define mesh on which to draw sinusoids
[x y]=meshgrid(-fix(sz/2):fix(sz/2),fix(-sz/2):fix(sz/2));
yr=-x*sin(angle)+y*cos(angle);
yc=-x*sin(angle+diff)+y*cos(angle+diff);

%make sinusoids with values ranging from 0 to 1 (i.e. contrast is positive)
grating=contc.*cos(freqc*yr+phasec);
cross=contm.*cos(freqm*yc+phasem);

%put togeter image from components
I=grating+cross;
I=0.5+0.5.*I; %note if contc & or contm >0.5 contrast of plaid could be >1