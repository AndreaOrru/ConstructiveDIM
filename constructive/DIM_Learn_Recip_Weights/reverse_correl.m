function [Wcorrel,X,I]=reverse_correl(W,V,sigmaLGN,X,I)
[n,m]=size(W);  
p=sqrt(m/2);

numPresentations=20; %number of times each image is presented
presentationTime=1; %number of iteration for which each image is presented each time
toff=0; %time offset at which to reconstrucuct RF.
border=odd(10*sigmaLGN)+1;
[plotRows,plotCols]=highest_integer_factors(n);

if nargin<5
  %create the image data set
  disp('generating image dataset')
  hartley=1
  if ~hartley
	numImages=1000; %number of distinct images in the data set
	imageSize=p+border; %size, in pixels, of each image
	for k=1:numImages
	  wavel=2+rand*imageSize/2;
	  angle=rand*180;
	  phase=rand*360;
	  Iover(:,:,k)=image_square_grating(imageSize,0,wavel,angle,phase,0.5);
	end
   else
	 Iover=hartley_subspace(p,border,floor(p/2),0.125);
  end
  
  Iover=single(Iover);
  [a,b,numImages]=size(Iover);
  numImages
  %pre-process images to generate V1 input stimuli
  disp('preprocessing and resizing image dataset')
  Xover=preprocess_V1_input(Iover,sigmaLGN);

  figure(6),clf
  for t=1:min(30,numImages), maxsubplot(5,6,t),imagesc(Iover(:,:,t));
	axis('equal','tight'), set(gca,'XTick',[],'YTick',[]); drawnow;
  end
  figure(7),clf
  for t=1:min(30,numImages), maxsubplot(5,6,t),imagesc(Xover{1}(:,:,t));
  	axis('equal','tight'), set(gca,'XTick',[],'YTick',[]); drawnow;
  end
  %remove edges from V1 inputs to avoid edge effects caused by LGN filters
  for k=1:numImages
	%take the ON and OFF channels and combine them into a single input vector
	xonoff=[Xover{1}(1+border/2:a-border/2,1+border/2:b-border/2,k),...
			Xover{2}(1+border/2:a-border/2,1+border/2:b-border/2,k)];
	X(:,k)=xonoff(:);
	I(:,:,k)=Iover(1+border/2:a-border/2,1+border/2:b-border/2,k);
  end
 
  figure(8),clf
  for t=1:min(30,numImages), 
	maxsubplot(5,6,t),
	imagesc(reshape(X(1:m/2,t),p,p));
	%imagesc(I(:,:,t),[0,1]);
  	axis('equal','tight'), set(gca,'XTick',[],'YTick',[]); drawnow;
  end
end
iterations=numImages*presentationTime;

for trial=1:numPresentations
  trial
  disp('generating image sequence')
  %compile pre-processed images into a sequence where each image is shown for in
  %random order for the specified number of iterations
  presentationOrder=randperm(numImages);
  t=0;
  for k=1:numImages
	for i=1:presentationTime
	  t=t+1;
	  Xseq(:,t)=X(:,presentationOrder(k));
	  Iseq(:,:,t)=I(:,:,presentationOrder(k));
	end
  end
  
  disp('recording responses')
  %Present images to V1 model
  [ytrace]=dim_activation_sequence(W,Xseq,iterations,V);

  disp('calculating reverse correlations for trial');
  Icorrel_mean=calc_reverse_correl(Iseq,ytrace,toff);
  for node=1:n
	Icorrel{node}(:,:,trial)=Icorrel_mean{node};
  end

  disp('plotting reverse correlations')
  figure(9), clf  
  for node=1:n
	%for each node show the RF reconstructed from the reverse correlation
	Icorrel_mean=mean(Icorrel{node},3);
	lim=max(1e-4,0.95.*max(max(abs(Icorrel_mean))));
	maxsubplot(plotRows,plotCols,node)
	imagesc(Icorrel_mean,[-lim,lim]);
	axis('equal','tight'), set(gca,'XTick',[],'YTick',[]); drawnow;	
	Wcorrel(node,:)=Icorrel_mean(:)';
  end
end
cmap=colormap('gray');
cmap=1-cmap;
colormap(cmap);
set(gcf,'PaperPosition',[1 1 plotCols plotRows]);




function Icorrel=calc_reverse_correl(Isequence,ytrace,toff)
[n,iterations]=size(ytrace);

%ignore 1st response in each trial
ytrace=ytrace(:,2:iterations);
Isequence=Isequence(:,:,2:iterations);
iterations=iterations-1;

Isequence=Isequence-0.5; %subtrace mean luminance from images
for node=1:n
  %for each node with an RF centred at the middle of the image 
  resp(1:iterations)=ytrace(node,:);
  %resp=max(0,resp-mean(resp));

  %calculate correlation between response and input image at previous times
  i=0;
  for t=toff+1:iterations
	i=i+1;
	%correlation between response at time t and image at time i
	Icorrel_comp(:,:,i)=resp(t).*Isequence(:,:,i); 
  end
  %mean correlation over all images
  Icorrel{node}(:,:)=mean(Icorrel_comp,3);
end