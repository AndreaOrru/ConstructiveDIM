function Patch=rand_patch_onoff(Ion,Ioff,p,sigmaLGN,vec_not_cell)
[a,b]=size(Ion);
crop=ceil(5*sigmaLGN); %avoid image edges due to possible edge effects caused
                       %by pre-processing.
x=randi([1+crop,b-crop-p+1],1);
y=randi([1+crop,a-crop-p+1],1);

Pon=Ion([y:y+p-1],[x:x+p-1]);
Poff=Ioff([y:y+p-1],[x:x+p-1]);

%[x y]=meshgrid(-fix(p/2):fix(p/2),fix(-p/2):fix(p/2));
%radius=sqrt(x.^2+y.^2);
%Pon(find(radius>floor(p/2)))=0;
%Poff(find(radius>floor(p/2)))=0;

if nargin<5 | vec_not_cell==1
  Patch=[Pon,Poff];
  Patch=Patch(:);
else
  Patch{1}=Pon;
  Patch{2}=Poff;
end
