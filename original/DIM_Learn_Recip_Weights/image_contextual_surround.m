function I=image_contextual_surround(csize,vsize,ssize,cwavel,swavel,anglec,angles,cphase,sphase,contc,conts)
% csize  = the diameter of the centre patch (pixels)
% vsize  = the width of the blank area between the centre and surround
% ssize  = the width of the surrounding annulus  (pixels)
% cwavel  = the wavelength of the sin wave in the centre patch (pixels)
% swavel  = the wavelength of the sin wave in the surround (pixels)
% anglec = orinetation of centre sinusoid
% angles = orientation of surround sinusoid
% cphase = the phase of the central patch
% sphase = the phase of the surround
% contc = contrast of central patch
% conts = contrast of surround

cfreq=2*pi./cwavel;
sfreq=2*pi./swavel;
anglec=-anglec*pi/180;
angles=-angles*pi/180;
cphase=cphase*pi/180;
sphase=sphase*pi/180;

%define image size
sz=fix(csize+2*vsize+2*ssize);
if mod(sz,2)==0, sz=sz+1;end %image has odd dimension
I=zeros(sz);

%define mesh on which to draw sinusoids
[x y]=meshgrid(-fix(sz/2):fix(sz/2),fix(-sz/2):fix(sz/2));
err=0;%10*pi/180;
yc=-x*sin(anglec+err)+y*cos(anglec+err);
yr=-x*sin(angles+err)+y*cos(angles+err);

%make sinusoids with values ranging from 0 to 1 (i.e. contrast is positive)
center=0.5+0.5.*contc.*cos(cfreq*yc+cphase);
surround=0.5+0.5.*conts.*cos(sfreq*yr+sphase);

%define radius from centre point
radius=sqrt(x.^2+y.^2); %for circular gratings
%radius=max(abs(x),abs(y)); %for square gratings

%put togeter image from components
I=surround;
I(find(radius<vsize+csize/2))=0.5;
I(find(radius<csize/2))=center(find(radius<csize/2));
I(find(radius>ssize+vsize+csize/2))=0.5;

