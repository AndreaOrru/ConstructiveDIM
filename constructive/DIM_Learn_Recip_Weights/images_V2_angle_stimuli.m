function Iseq=images_V2_angle_stimuli(imsz)
hlen=ceil(imsz/4);
clip=hlen;
len=2*hlen+1;
cent=2*hlen+clip;
wid=2.5;
bar=define_bar(len,wid);
contrast=-0.5;
k=0;
for ang1=330:-30:0
  for ang2=0:30:330
	%if ang1~=ang2
	  k=k+1;
	  
	  %if ang1<=ang2
	  %	contrast=-0.5;
	  %else
      %  contrast=0.5;
	  %end
	  I=zeros(imsz+2*hlen)+0.5;

	  x=round(cent-hlen*sin(ang1*pi/180));
	  y=round(cent+hlen*cos(ang1*pi/180));
	  I=draw_bar(I,x,y,bar,ang1,contrast,0.5);

	  x=round(cent-hlen*sin(ang2*pi/180));
	  y=round(cent+hlen*cos(ang2*pi/180));
	  I=draw_bar(I,x,y,bar,ang2,contrast,0.5);

	  I=I(clip+1:imsz+2*hlen-clip,clip+1:imsz+2*hlen-clip);
	  Iseq(:,:,k)=I;
	%end
  end
end

function bar=define_bar(len,wid);
%draw a bar with maximum intensity=1 against a background with intensity=0.

maxlen=odd(len,1);
minlen=odd(len,0);
maxwid=odd(wid,1);
minwid=odd(wid,0);

bar=zeros(max(maxlen,maxwid)+2);
cent=ceil((max(maxlen,maxwid)+2)/2);

lenval=(len-max(0,minlen));
if minlen>=1; lenval=lenval/2; end
widval=(wid-max(0,minwid));
if minwid>=1; widval=widval/2; end

hlen=floor(maxlen/2);
hwid=floor(maxwid/2);
bar(cent-hwid:cent+hwid,cent-hlen:cent+hlen)=lenval*widval;

hlen=floor(maxlen/2);
hwid=floor(minwid/2);
bar(cent-hwid:cent+hwid,cent-hlen:cent+hlen)=lenval;

hlen=floor(minlen/2);
hwid=floor(maxwid/2);
bar(cent-hwid:cent+hwid,cent-hlen:cent+hlen)=widval;

hlen=floor(minlen/2);
hwid=floor(minwid/2);
bar(cent-hwid:cent+hwid,cent-hlen:cent+hlen)=1;

function I=draw_bar(I,x,y,bar,angle,contrast,backgnd)
%if nargin<6, contrast=1; end
%if nargin<7, backgnd=0.5; end

bar=imrotate(bar,angle,'bilinear','crop');
bar=(bar.*contrast)+backgnd;
len=size(bar,1);
hlen=fix((len-1)/2);
if contrast>=0;
  I(x-hlen:x+hlen,y-hlen:y+hlen)=max(I(x-hlen:x+hlen,y-hlen:y+hlen),bar);
else
  I(x-hlen:x+hlen,y-hlen:y+hlen)=min(I(x-hlen:x+hlen,y-hlen:y+hlen),bar);
end