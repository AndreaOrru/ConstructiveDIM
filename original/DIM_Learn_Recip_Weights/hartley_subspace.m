function H=hartley_subspace(sz,border,span,step)
hsz=floor(sz/2);
if nargin<3 | isempty(span), span=hsz; end
if nargin<4 | isempty(step), step=1; end
num=length([-span:step:span])^2
k=0; 
for ky=-span:step:span,
  for kx=-span:step:span, 
	k=k+1; 
	h=hartley_image(kx,ky,sz,border);
	H(:,:,k)=0.5+0.5.*h./sqrt(2);      %positive, rescaled to be between 0 and 1
	H(:,:,num+k)=0.5+0.5.*-h./sqrt(2);;%negative, rescaled to be between 0 and 1
  end
end
k

function H=hartley_image(kx,ky,sz,border)
imsize=sz+border;
[x y]=meshgrid(-fix(imsize/2):fix(imsize/2),fix(-imsize/2):fix(imsize/2));

arg=(2*pi.*(kx.*x+ky.*y))./sz;
H=sin(arg)+cos(arg);
