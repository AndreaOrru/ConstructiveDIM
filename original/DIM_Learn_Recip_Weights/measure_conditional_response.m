function [Y]=measure_conditional_response(W,V,node,Y)
%DEFINE NETWORK PARAMETERS
iterations=200;           %number of iterations to calculate y (for each input)
[n,m]=size(W);
p=sqrt(m/2); %calc rf diam (assuming on/off channels and square rf)
cycs=20000;               %number of image presentations
num2compare=5;

%GENERATE TEST DATA
sigmaLGN=1.5;
%load natural images
load('IMAGES_RAW_Olshausen.mat');
%load('IMAGES_RAW_VanHateren.mat');
%load('/home/store/Data/Olshausen_natural_images/IMAGES_RAW.mat');
%load('/home/store/Data/VanHateren_natural_images/IMAGES_RAW.mat');
nI=size(IMAGESr,3);

%normalise greyscale of each image 
for k=1:nI
  I(:,:,k)=IMAGESr(:,:,k)-min(min(IMAGESr(:,:,k)));
  I(:,:,k)=I(:,:,k)./max(max(I(:,:,k)));
end
%convolve images with LOG filter and separate into ON and OFF channels
X=preprocess_V1_input(I,sigmaLGN);

if nargin<4 | isempty(Y)
  %TEST NETWORK RESPONSE
  for k=1:cycs
	if rem(k,1000)==0, fprintf(1,'.%i.',k); end %pause(60); end
	
	%choose an input stimulus
	i=randi([1,nI],1);
	x=rand_patch_onoff(X{1}(:,:,i),X{2}(:,:,i),p,sigmaLGN); 
	
	%calculate node activations
	y=dim_activation(W,x,[],iterations,V);
	Y(:,k)=y; %record response of all nodes
  end
end

%PLOT RESULTS
clf
RFs=reconstruct_V1RF(W,[p,p],sigmaLGN);
RFs=RFs(:,1:m/2)-RFs(:,m/2+1:m);
lim=max(1e-9,0.95.*max(abs(RFs(node,:))));
maxsubplot(2,num2compare+1,1),
imagesc(flipud(reshape(RFs(node,:),p,p)'),[-lim,lim])
axis('equal','tight','off'); set(gca,'XTick',[],'YTick',[]);
for k=1:num2compare
  secondnode=node;
  while secondnode==node
	secondnode=randi(n,1);
  end
  secondnode
  lim=max(1e-9,0.95.*max(abs(RFs(secondnode,:))));
  maxsubplot(2,num2compare+1,num2compare+2+k),
  imagesc(flipud(reshape(RFs(secondnode,:),p,p)'),[-lim,lim]); 
  axis('equal','tight','off'); set(gca,'XTick',[],'YTick',[]); 
  maxsubplot(2,num2compare+1,1+k),
  H=plot_joint_histogram(Y(node,:),Y(secondnode,:));
  set(gca,'XTick',[],'YTick',[]);
end
cmap=colormap('gray');
cmap=1-cmap;
colormap(cmap);
set(gcf,'PaperPosition',[1 1 num2compare+1 2]);



%%varvar=[]; for i=1:n, i, for j=1:n, if i~=j, H=plot_joint_histogram(Y(i,:),Y(j,:)); varvar=[varvar,var(var(H))]; end, end, end, mean(varvar)
