function measure_reconstruction_error(W,V)
%Measure the NMSE between an image patch and the reconstruction of that image patch 
%W and V = the learnt FF and FB weights

%DEFINE NETWORK PARAMETERS
iterations=200;     %number of iterations to calculate y (for each input)
[n,m]=size(W);
p=sqrt(m/2);        %RF width (assuming on/off channels and square rf)
cycs=20000;         %number of patches to be reconstructed
recons2plot=3;      %the number of exemplar patch reconstructions to plot

%GENERATE TEST DATA
sigmaLGN=1.5;
%load natural images
load('IMAGES_RAW_Olshausen.mat');
nI=size(IMAGESr,3);

%normalise greyscale of each image 
for k=1:nI
  I(:,:,k)=IMAGESr(:,:,k)-min(min(IMAGESr(:,:,k)));
  I(:,:,k)=I(:,:,k)./max(max(I(:,:,k)));
end
%convolve images with LOG filter and separate into ON and OFF channels
X=preprocess_V1_input(I,sigmaLGN);

%TEST NETWORK RESPONSE
clf
for k=1:cycs
  if rem(k,1000)==0, fprintf(1,'.%i.',k); end %pause(60); end
  
  %choose an input stimulus
  i=randi([1,nI],1);
  x=rand_patch_onoff(X{1}(:,:,i),X{2}(:,:,i),p,sigmaLGN); 

  %calculate node activations
  y=dim_activation(W,x,[],iterations,V);

  error(k)=sum((x-V'*y).^2)./sum(x.^2); %NMSR
  %error(k)=sum((x-V'*y).^2);%Euclidian
  if k<=recons2plot
	error(k)
	xonoff=reshape(x(1:m/2)-x(m/2+1:m),p,p);
	%xonoff=[reshape(x(1:m/2),p,p),reshape(x(m/2+1:m),p,p)];
	r=V'*y;
	ronoff=reshape(r(1:m/2)-r(m/2+1:m),p,p);
	%ronoff=[reshape(r(1:m/2),p,p),reshape(r(m/2+1:m),p,p)];
	ronoff=max(xonoff(:)).*ronoff./max(ronoff(:));
	lim=max(1e-9,max(max(abs(xonoff))));
	maxsubplot(3,recons2plot,k+2*recons2plot)
	imagesc(xonoff,[-lim,lim]);
	axis('equal','tight'); set(gca,'XTick',[],'YTick',[]);
	maxsubplot(3,recons2plot,k+recons2plot)
	imagesc(ronoff,[-lim,lim]);
	axis('equal','tight'); set(gca,'XTick',[],'YTick',[]);
	maxsubplot(3,recons2plot,k)
	imagesc(ronoff-xonoff,[-lim,lim]);
	axis('equal','tight'); set(gca,'XTick',[],'YTick',[]);
  end
end
disp(['mean=',num2str(mean(error)),' median=',num2str(median(error)),...
	  ' max=',num2str(max(error)),' min=',num2str(min(error))]);
	  
