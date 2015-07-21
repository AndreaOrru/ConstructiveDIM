function [X,W,V,U]=learn_natural_image_patches(X,W,V,U,cycs)
%DEFINE NETWORK PARAMETERS
beta=0.005;               %learning rate
iterations=200;           %number of iterations to calculate y (for each input)
p=11;                     %length of one side of input image
n=180;                    %number of nodes
m=2*p^2;                  %number of inputs
if nargin<5
  cycs=20000;               %number of training cycles 
end
show=5000;                %how often to plot receptive field data
continuousLearning=0;    %learn at every iteration, or using steady-state responses


%GENERATE TRAINING DATA
sigmaLGN=1.5;
if nargin<1 || isempty(X)
  %load natural images
  load('IMAGES_RAW_Olshausen.mat');
  %load('IMAGES_RAW_VanHateren.mat');
  nI=size(IMAGESr,3);
  
  %normalise greyscale of each image 
  for k=1:nI
	I(:,:,k)=IMAGESr(:,:,k)-min(min(IMAGESr(:,:,k)));
	I(:,:,k)=I(:,:,k)./max(max(I(:,:,k)));
  end
  %convolve images with LOG filter and separate into ON and OFF channels
  X=preprocess_V1_input(I,sigmaLGN);
else
  nI=size(X{1},3);
end


%DEFINE INITIAL WEIGHTS
if nargin<3 || isempty(W),
  [W,V,U]=weight_initialisation_random(n,m);
  %W=W./2;
  %V=V.*2;
  %U=U.*2;
else
  [n,m]=size(W);
  p=sqrt(m/2);
end
figure(1), plot_weights(W,[p,p]);

ymax=0;
y=[];e=[];
%TRAIN NETWORK
for k=1:cycs
  if rem(k,1000)==0, fprintf(1,'.%i.',k); end %pause(60); end
  
  %choose an input stimulus
  i=randi([1,nI],1);
  x=rand_patch_onoff(X{1}(:,:,i),X{2}(:,:,i),p,sigmaLGN); 

  if continuousLearning  
	%calculate node activations and learn
	[y,e,W,V,U]=dim_activation(W,x,y,1+floor(rand*2*iterations),V,beta/iterations,U);
  else 
	%OR calculate node activation then learn
	[y,e]=dim_activation(W,x,y,iterations,V);
	[W,V]=dim_learn(W,V,y,e,beta);
	U=dim_learn_feedback(U,y,x,beta);
  end
  
  ymax=max([ymax,max(y)]);
  %show results
  if rem(k,show)==0,
	set(0,'CurrentFigure',1); plot_weights(W,[p,p]); 
	disp([' ymax=',num2str(ymax),' wSum=',num2str(max(sum(W'))),...
		  ' vSum=',num2str(max(sum(V'))),' uSum=',num2str(max(sum(U')))]);
	ymax=0;
  end
end

%PLOT RESULTS
%plot reconstructed on-off weights
figure(1), plot_weights(reconstruct_V1RF(W,[p,p],sigmaLGN),[p,p]);
figure(2), plot_weights(reconstruct_V1RF(V,[p,p],sigmaLGN),[p,p]);
figure(3), plot_weights(reconstruct_V1RF(U,[p,p],sigmaLGN),[p,p]);
%plot on-channels
figure(4), plot_weights(W(:,1:m/2),[p,p])
figure(5), plot_weights(V(:,1:m/2),[p,p])
figure(6), plot_weights(U(:,1:m/2),[p,p])
%plot off-channels
figure(7), plot_weights(W(:,m/2+1:m),[p,p])
figure(8), plot_weights(V(:,m/2+1:m),[p,p])
figure(9), plot_weights(U(:,m/2+1:m),[p,p])
disp(' ');




function plot_weights(W,shape)
scale_bar=0;
[n,m]=size(W);
%n=min(24,n);
[plotRows,plotCols]=highest_integer_factors(n);
neg=0;
%if weights are for both on and off channels then effective weight is on-off
if m==2*prod(shape)
  W=W(:,1:m/2)-W(:,m/2+1:m);
  neg=1;
end
clf
lim=max(1e-9,0.85.*max(max(abs(W))));
for j=1:n, 
  maxsubplot(plotRows+scale_bar,plotCols,j+(scale_bar*plotCols)),
  if ~scale_bar
	lim=max(1e-9,0.95.*max(abs(W(j,:))));
  end
  imagesc(reshape(W(j,:),shape),[-lim*neg,lim]),
  axis('equal','tight'); set(gca,'XTick',[],'YTick',[]); 
end
cmap=colormap('gray'); 
cmap=1-cmap;
colormap(cmap);
%colorbar
drawnow
if scale_bar
  maxsubplot(plotRows+scale_bar,1,1)
  plot_bar([-lim*neg,lim],'t');
end
set(gcf,'PaperPosition',[1 1 plotCols plotRows]);





function plot_bar(range,position)
imagesc(range(1),range); 
axis('off')
if position=='l'
  colorbar('East');
elseif position=='r'
  colorbar('West');
elseif position=='t'
  colorbar('North');
elseif position=='b'
  colorbar('South');
end


