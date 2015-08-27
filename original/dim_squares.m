function recognized = dim_squares()

tic

%set network parameters
beta=0.05;                %learning rate
iterations=50;            %number of iterations to calculate y (for each input)
epsilon=1e-10;

%define task
p=6;                     %length of one side of input image
s=3;                     %size of square image components
n=48;                    %number of nodes
m=p*p;                   %number of inputs
cycs=20000;              %number of training cycles 
show=1000;               %how often to plot receptive field data
patterns=1000;           %number of training patterns in training set
numsquares=(p-s+1).^2;
probs=0.1*ones(1,numsquares);
mincontrast=1; 
%probs=0.02+0.18*rand(1,numsquares);
%mincontrast=0.1;

%generate a fixed pattern set
clear data
for k=1:patterns
  data(:,k)=squares_pattern_randprob(p,s,probs,mincontrast);
end
  
%define initial weights
W=(1/16)+(1/64).*randn(n,m);%Gassian distributed weights with given
							%mean and standard deviation				   
W(find(W<0))=0;			

%learn receptive fields
for k=1:cycs
  if rem(k,1000)==0, fprintf(1,'.%i.',k); end
  
  patternNum=fix(rand*patterns)+1; %random order
  x=data(:,patternNum);

  What=W./(epsilon+(max(W')'*ones(1,m)));%weights into nodes normalised by
                                         %maximum value
										 
  %iterate to calculate node activations
  y=zeros(n,1);
  for i=1:iterations
	e=x./(epsilon+(What'*y));
	y=(epsilon+y).*(W*e);
  end 
  %update weights
  W=W.*( 1 + beta.*( y*(e'-1) ));
  W(find(W<0))=0; 

  if rem(k,show)==0,
	%show weights
	recognized = squares_plot(s,W);
  end
end

s=sum(W'), disp(num2str([max(s),min(s),max(max(W)),min(min(W))]))
disp('');

toc



function [x,patterns,input_set_components]=squares_pattern_randprob(m,s,prob,mincontrast)
%function [x,patterns,input_set_components]=squares_pattern_randprob(m,s,prob,mincontrast)
%
%create a mxm pixel image in which overlapping sxs squares are randomly
%active with probability 'prob', where prob is a vector defining the
%independent probability for each separate componenet.
%The contast of each component is assigned randomly (between mincontrast and
%1) in each generated pattern.

nsquares=(m-s+1);

%choose one square to be present, so that each pattern will contain at least one
%square. Need to make choice based on probability of each component being
%present.
c=rand*sum(prob);
included=min(find(c<cumsum(prob)));
depthorder=randperm(nsquares^2);%randomly assign a depth to each possible 
								%component to decide which contrast goes on top
%randomly assign a contrast between mincontrast and 1 to each possible component
contrast=mincontrast+(1-mincontrast).*rand(1,nsquares^2);

%add patterns to input
npattern=0;
patterns=[];
x=zeros(m,m);
depth=zeros(m,m);
for c=1:nsquares
  for r=1:nsquares
	npattern=npattern+1;
	if (rand<prob(npattern) | npattern==included) & contrast(npattern)>0
	  %decide at which pixels current component is infront
	  depth(r:r+s-1,c:c+s-1)=max(depth(r:r+s-1,c:c+s-1), ...
								 depthorder(npattern));
	  %fill in those pixels with contrast of current component
	  for j=r:r+s-1
		for i=c:c+s-1
		  if depth(j,i)==depthorder(npattern)
			x(j,i)=contrast(npattern);
		  end
		end
	  end
	  
	  %record fact that this component has been selected
	  patterns=[patterns,npattern];
	end
  end
end


%remove any patterns from the list of included patterns that are entirely
%occluded by other patterns
npattern=0;
occludedpatterns=[];
for c=1:nsquares
  for r=1:nsquares
	npattern=npattern+1;
	if ismember(npattern,patterns)
	  %see if this pattern is ontop at any pixel
	  if ~ismember(depthorder(npattern),depth(r:r+s-1,c:c+s-1));
		occludedpatterns=[occludedpatterns,npattern];
	  end
	end
  end
end

patterns=setdiff(patterns,occludedpatterns);

x=x(:);
if sum(x)==0
  disp('missing');
  [x,patterns,input_set_components]=squares_pattern(m,s,prob,noise);
end
  
input_set_components=zeros(1,nsquares^2);
input_set_components(patterns)=1;




function [nrepanycomplete]=squares_plot(sqsize,weights)
%function [nrepanycomplete]=squares_plot(sqsize,weights)

if nargin<2
  weights=load('weights_1basal.dat');
end
[n,m]=size(weights);
p=sqrt(m);
scale=max(max(weights))*0.85;

plot_per_row=min(n,8);
num_rows=ceil(n/plot_per_row);
clf

sqsize=sort(sqsize);
nsqsizes=length(sqsize);
totalsquares=0;
for k=1:nsqsizes
  s=sqsize(k);
  totalsquares=totalsquares+(p-s+1)^2;
end
representedcomplete=zeros(1,totalsquares);

for j=1:n
  
  w=reshape(weights(j,:),p,p);
  subplot(num_rows,plot_per_row,j),hinton_plot(w,scale,3,1,1);
  
  %determine degree of match between weights and all possible input patterns
  npattern=0;
  lpref=[];
  for k=1:nsqsizes
	s=sqsize(k);
	nsquares=(p-s+1);
	for c=1:nsquares
	  for r=1:nsquares
		npattern=npattern+1;
		wOut=w; wOut(r:r+s-1,c:c+s-1)=0;
		wIn=w(r:r+s-1,c:c+s-1);
		
		if sum(sum(wIn))>3*sum(sum(max(0,wOut))) & ...
			  min(min(wIn))>max(max(wOut)) & ...
			  min(min(wIn))>mean(mean(max(0,w)))
		  lpref=[lpref,npattern];
		end
	  end
	end
  end
  if length(lpref)>1
	lpref
  end
  
  representedcomplete(lpref)=representedcomplete(lpref)+1;
	
  if representedcomplete(lpref)>1, 
	text(1,0.25,['(',int2str(lpref),')']);
  else
	text(1,0.25,int2str(lpref));
  end	
end
nrepanycomplete=length(find(representedcomplete>0));
disp(['network represents ', int2str(nrepanycomplete), ' patterns ']);
norep=find(representedcomplete==0);
if length(norep>1) disp(['FAILED to represent pattern = ',int2str(norep)]); end



function hinton_plot(W, scale, colour, type, equal)
%function hinton_plot(W, scale, colour, type, equal)
% type 0 = variable size boxes (size relates to strength)
% type 1 = image (color intensity relates to strength)
% type 2 = equal size squares (color intensity relates to strength)
% type 3 = same as type 0 but with outerboarder showing maximum size of box

W(find(W<0))=0;

if (type==1)
  %draw as an image: strength indicated by pixel darkness
  
  %W is true data value (greater than 0) and is scaled to be between 0 and 255
  imagesc(uint8(round((W./scale)*255)),[0,255]);%,'CDataMapping','scaled'),
  colormap(gray)
  map=colormap;
  map=flipud(map);
  map(1:64,colour)=map(1:64,colour)*0.0+1;%*0.33+0.66;
  colormap(map)
  axis on
  if(equal==1), axis equal, end
  if(equal==1), axis tight, end
  
elseif (type==0 | type==3)
  %draw as squares: strength indicated by size of square

  colstr=['r','g','b'];
  if(equal==0)
	%calc aspect ratio - if not going to set axis equal
	plot(size(W,2)+0.5,size(W,1)-0.5,'bx');
	hold on 
	plot(0.5,-0.5,'bx');
	axis equal
	a=axis;
	aspectX=size(W,2)/abs(a(2)-a(1));
	aspectY=size(W,1)/abs(a(4)-a(3));
	aspectXX=aspectX./max(aspectX,aspectY);
	aspectYY=aspectY./max(aspectX,aspectY);
	hold off
  else
	aspectXX=1;
	aspectYY=1;
  end
  for i=1:size(W,2)
	for j=1:size(W,1)
	  box_widthX=aspectXX*0.5*W(j,i)/(scale);
	  box_widthY=aspectYY*0.5*W(j,i)/(scale);
	  h=fill([i-box_widthX,i+box_widthX,i+box_widthX,i-box_widthX],size(W,1)+1-[j-box_widthY,j-box_widthY,j+box_widthY,j+box_widthY],colstr(colour));
	  hold on
	  if (isnan(W(j,i)))
		plot(i,size(W,1)+1-j,'kx','MarkerSize',20);
	  end
	  
	  if (type==3)
		set(h, 'EdgeColor','w');
		box_widthX=aspectXX*0.5*1;
		box_widthY=aspectYY*0.5*1;
		h=fill([i-box_widthX,i+box_widthX,i+box_widthX,i-box_widthX],size(W,1)+1-[j-box_widthY,j-box_widthY,j+box_widthY,j+box_widthY],'w','FaceAlpha',0);
	  end
	  
	end
  end
  %axis off
  %axis tight

  if(equal==1), axis equal, end
  axis([0.5,size(W,2)+0.5,+0.5,size(W,1)+0.5])

else
  %draw as equal sized squares: strength indicated by darkness of square

  if(equal==0)
	%calc aspect ratio - if not going to set axis equal
	plot(size(W,2)+0.5,size(W,1)-0.5,'bx');
	hold on 
	plot(0.5,-0.5,'bx');
	axis equal
	a=axis;
	aspectX=size(W,2)/abs(a(2)-a(1));
	aspectY=size(W,1)/abs(a(4)-a(3));
	aspectXX=aspectX./max(aspectX,aspectY);
	aspectYY=aspectY./max(aspectX,aspectY);
	hold off
  else
	aspectXX=1;
	aspectYY=1;
  end
  box_widthX=aspectXX*0.33;
  box_widthY=aspectYY*0.33;
  for i=1:size(W,2)
	for j=1:size(W,1)
	  fill([i-box_widthX,i+box_widthX,i+box_widthX,i-box_widthX],size(W,1)+1-[j-box_widthY,j-box_widthY,j+box_widthY,j+box_widthY],ones(1,4).*round((W(j,i)./scale)*255),'FaceColor','flat');
	  hold on
	end
  end
  colormap(gray)
  map=colormap;
  map=flipud(map);
  map(1:64,colour)=map(1:64,colour)*0.0+1;%*0.33+0.66;
  colormap(map)
  caxis([0,255])%if we remove this then each subplot is scaled independently
  %axis off
  %axis tight

  if(equal==1), axis equal, end
  axis([0.5,size(W,2)+0.5,+0.5,size(W,1)+0.5])
  
end
%set(gca,'YTickLabel',[' ';' ';' ';' ';' ';' ';' '])
%set(gca,'XTickLabel',[' ';' ';' ';' ';' ';' ';' '])
set(gca,'YTick',[])
set(gca,'XTick',[])
drawnow

