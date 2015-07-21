function [X,Wrecon,Vrecon,Urecon,W,V,U]=learn_natural_image_patches_hierarchy(X,W,V,U,cycs)
%DEFINE NETWORK PARAMETERS
beta=0.005;               %learning rate
iterations=200;           %number of iterations to calculate y (for each input)
p=23                      %length of one side of input patch
%p=35
m=2*p^2;                  %number of inputs
if nargin<5
  cycs=20000;               %number of training cycles 
end
show=1000;                %how often to plot receptive field data
minfigs=1;
continuousLearning=0;    %learn at every iteration, or using steady-state responses



%GENERATE TRAINING DATA
sigmaLGN=1.5;
if cycs>0 
  if nargin<1 | isempty(X)
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
  else
	nI=size(X{1},3);
  end
end


%DEFINE INITIAL WEIGHTS
if nargin<2 | isempty(W)
  numStages=2;%not counting input - however arrays nr and npr include input
			  %parameters, so index these arrarys using stage number +1

  if numStages==2	%define a 2-stage hierarchy
	nr=[m,9,1];       %number of regions in each processing stage
	npr=[1,40,180]    %number of nodes in each region of each processing stage
	%nr=[m,25,9];       %number of regions in each processing stage
	%npr=[1,40,100]    %number of nodes in each region of each processing stage
  else	%define a 3-stage hierarchy
	nr=[m,16,4,1];       %number of regions in each processing stage
	npr=[1,80,100,200];  %number of nodes in each region of each processing stage
  end

  %WIRE-UP HIERARCHY
  clear W V U
  for stage=1:numStages
	%initialise with random weights
	[W{stage},V{stage},U{stage}]=weight_initialisation_random(...
		npr(stage+1)*nr(stage+1),npr(stage)*nr(stage));

	%define the regions in preceding stage that provide input to each region of
	%the current stage: 
	if stage==1
	  ranges{stage}=split_range(nr(stage)/2,nr(stage+1),1);
	else
	  ranges{stage}=split_range(nr(stage),nr(stage+1),1);
	end
	%for each region set weights to zero, except within predefined RF
	for k=1:nr(stage+1)
	  nodesInRegion(k,:)=(k-1)*npr(stage+1)+1:k*npr(stage+1);
	end
	if stage==1
	  [W{stage},V{stage},U{stage}]=restrict_V1RF(W{stage},V{stage},U{stage},...
								nodesInRegion,nr(stage),npr(stage),ranges{stage});
	else
	  [W{stage},V{stage},U{stage}]=restrict_RF(W{stage},V{stage},U{stage},...
								nodesInRegion,nr(stage),npr(stage),ranges{stage});
	end
	clear nodesInRegion;
  end
else
  numStages=length(W);
  p=sqrt(size(W{1},2)/2)
end
if cycs>0
  for stage=1:numStages
	%plot reconstructed weights for each stage
	[Wrecon,Vrecon,Urecon]=reconstruct_RFstage(W,V,U,[p,p],sigmaLGN,stage);
	figure(1+3*(stage-1)), clf, plot_weights(Wrecon,[p,p]);
	if ~minfigs, figure(2+3*(stage-1)), clf, plot_weights(Vrecon,[p,p]); end
	if ~minfigs, figure(3+3*(stage-1)), clf, plot_weights(Urecon,[p,p]); end
  end
end


%TRAIN NETWORK
%initialise response
for stage=1:numStages+1
  ymax{stage}=0;
  y{stage}=[];
  z{stage}=[];
  lr{stage}=beta;
end
%calc response and adapt weights
for k=1:cycs
  if rem(k,1000)==0, fprintf(1,'.%i.',k); end %pause(60); end

  %if delaying learning in upper stages, initialise lr to zero above
  if k==1, lr{1}=beta; end
  if k==10000, lr{2}=beta; end
  if k==20000, lr{3}=beta; end

  %choose an input stimulus
  i=randi([1,nI],1);
  x{1}=rand_patch_onoff(X{1}(:,:,i),X{2}(:,:,i),p,sigmaLGN); 

  if continuousLearning  
	%calculate node activations and learn at every iteration
	for t=1:1+floor(rand*2*iterations)
	  for stage=1:numStages
		[y{stage},e{stage},z{stage},W{stage},V{stage},U{stage}]=...
			dim_activation_step(W{stage},x{stage},y{stage},V{stage},U{stage},...
								z{stage+1},lr{stage}./iterations);
		x{stage+1}=y{stage};%input to next stage equal to output from this
	  end
	end
  else
	%OR calculate steady-state node activations, then learn
	for t=1:iterations
	  for stage=1:numStages
		[y{stage},e{stage},z{stage}]=dim_activation_step(...
			W{stage},x{stage},y{stage},V{stage},U{stage},z{stage+1});
		x{stage+1}=y{stage};%input to next stage equal to output from this
	  end
	end
	for stage=1:numStages
	  [W{stage},V{stage}]=dim_learn(W{stage},V{stage},y{stage},e{stage},lr{stage});
	  U{stage}=dim_learn_feedback(U{stage},y{stage},x{stage},lr{stage});
	end
  end
  
  for stage=1:numStages
	ymax{stage}=max([ymax{stage},max(y{stage})]);  
  end
  %show results
  if rem(k,show)==0,
	%plot weights and RFs
	for stage=1:numStages
	  %plot reconstructed weights for each stage
	  [Wrecon,Vrecon,Urecon]=reconstruct_RFstage(W,V,U,[p,p],sigmaLGN,stage);
	  set(0,'CurrentFigure',1+3*(stage-1)), clf, plot_weights(Wrecon,[p,p]);
	  if ~minfigs, 
		set(0,'CurrentFigure',2+3*(stage-1)), clf, plot_weights(Vrecon,[p,p]);
		set(0,'CurrentFigure',3+3*(stage-1)), clf, plot_weights(Urecon,[p,p]);
	  end
	  disp(['STAGE ',int2str(stage),': ymax=',num2str(ymax{stage}),...
			' wSum=',num2str(max(sum(W{stage}'))),...
			' vSum=',num2str(max(sum(V{stage}'))),...
			' uSum=',num2str(max(sum(U{stage}')))]);
	  ymax{stage}=0; 
	end
  end
end
for stage=1:numStages
  %plot reconstructed weights for each stage
  [Wrecon,Vrecon,Urecon]=reconstruct_RFstage(W,V,U,[p,p],sigmaLGN,stage);
  figure(1+6*(stage-1)), clf, plot_weights(Wrecon,[p,p]); 
  if ~minfigs, figure(2+6*(stage-1)), clf, plot_weights(Vrecon,[p,p]); end
  if ~minfigs, figure(3+6*(stage-1)), clf, plot_weights(Urecon,[p,p]); end
  %plot reconstructed weights for central region of stage 
	nr=[m,9,1];       %number of regions in each processing stage
	npr=[1,48,180]    %number of nodes in each region of each processing stage
  if exist('nr')
	midRegion=nr(stage+1)/2;
	midStart=1+floor(midRegion)*npr(stage+1);
	midEnd=ceil(midRegion)*npr(stage+1);
	figure(4+6*(stage-1)); clf, plot_weights(Wrecon(midStart:midEnd,:),[p,p]);
	if ~minfigs, 
	  figure(5+6*(stage-1)); clf, plot_weights(Vrecon(midStart:midEnd,:),[p,p]);
	  figure(6+6*(stage-1)); clf, plot_weights(Urecon(midStart:midEnd,:),[p,p]);
	end
  end
end
%plot ON weights for stage 1
%figure(4+3*numStages); plot_weights(W{1}(:,1:m/2),[p,p]);
%figure(5+3*numStages); plot_weights(V{1}(:,1:m/2),[p,p]);
%figure(6+3*numStages); plot_weights(U{1}(:,1:m/2),[p,p]);
%plot OFF weights for stage 1
%figure(7+3*numStages); plot_weights(W{1}(:,m/2+1:m),[p,p]);
%figure(8+3*numStages); plot_weights(V{1}(:,m/2+1:m),[p,p]);
%figure(9+3*numStages); plot_weights(U{1}(:,m/2+1:m),[p,p]);




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


function plot_stage_weights(stage,W,V,U,nr,npr)
for weights=1:3
  set(0,'CurrentFigure',weights+3*(stage-1)); clf, 
  if weights==1, RF=W{stage}; elseif weights==2, RF=V{stage}; else RF=U{stage}; end
  lim=max(1e-9,max(max(RF)));
  numInputs=npr(stage)*nr(stage);
  [numInputCols,numInputRows]=highest_integer_factors(numInputs);
  
  numNodes=npr(stage+1)*nr(stage+1);
  [numCols,numRows]=highest_integer_factors(numNodes);
  for k=1:numNodes
	maxsubplot(numCols,numRows,k)
	imagesc(flipud(reshape(RF(k,:),numInputRows,numInputCols)'),[0,0.9*lim]);
	axis('equal','tight'),set(gca,'XTick',[],'YTick',[]);
  end
end


function [Wrecon,Vrecon,Urecon]=reconstruct_RFstage(W,V,U,shape,sigma,numStages)
%reconstruct the RF of the nodes in a higher stage of the hierarchy
if nargin<6
  numStages=length(W); %reconstruct RF for final processing stage
end

Wrecon=W{1};
Vrecon=V{1};
Urecon=U{1};
for stage=2:numStages
  Wrecon=W{stage}*Wrecon;
  Vrecon=V{stage}*Vrecon;
  Urecon=U{stage}*Urecon;
end
Wrecon=reconstruct_V1RF(Wrecon,shape,sigma);
Vrecon=reconstruct_V1RF(Vrecon,shape,sigma);
Urecon=reconstruct_V1RF(Urecon,shape,sigma);


function [W,V,U]=restrict_V1RF(W,V,U,nodes,p,npr,ranges)
%for each set of "nodes" set the weights to zero outside of specified RF range
p=sqrt(p/2);%size of each on and off sub-field
r=0;
for x=1:size(ranges,1)
  for y=1:size(ranges,1)
	r=r+1;
	region=zeros(p,p);%the input regions form a square
	region(ranges(x,:),ranges(y,:))=1; %select those regions to provide input
	row=0;
	for c=1:p
	  for d=1:npr
		row=row+1;
		regionNodes(row,:)=region(c,:);%select all nodes making up those regions
	  end
	end
	regionNodes=regionNodes(:)';
	%multiply weights by the masks defined above in order to remove weights
    %from regions outside the RF
	on=1:p.^2; %range of inputs defining the ON channel
	off=1+p.^2:2*p.^2; %range of inputs defining the OFF channel
	for j=nodes(r,:)
	  W(j,on)=W(j,on).*regionNodes; %restrict on field
	  W(j,off)=W(j,off).*regionNodes; %restrict off field
	  V(j,on)=V(j,on).*regionNodes;
	  V(j,off)=V(j,off).*regionNodes;
	  U(j,on)=U(j,on).*regionNodes;
	  U(j,off)=U(j,off).*regionNodes;
	end
	clear regionNodes;
  end
end

function [W,V,U]=restrict_RF(W,V,U,nodes,p,npr,ranges)
%for each set of "nodes" set the weights to zero outside of specified RF range
p=sqrt(p);
r=0;
for x=1:size(ranges,1)
  for y=1:size(ranges,1)
	r=r+1;
	region=zeros(p,p);%the input regions form a square
	region(ranges(x,:),ranges(y,:))=1; %select those regions to provide input
	row=0;
	for c=1:p
	  for d=1:npr
		row=row+1;
		regionNodes(row,:)=region(c,:);%select all nodes making up those regions
	  end
	end
	regionNodes=regionNodes(:)';
	%multiply weights by the masks defined above in order to remove weights
    %from regions outside the RF
	for j=nodes(r,:)
	  W(j,:)=W(j,:).*regionNodes;
	  V(j,:)=V(j,:).*regionNodes;
	  U(j,:)=U(j,:).*regionNodes;
	end
	clear regionNodes;
  end
end

