function [yMean]=test_response_of_V2(W,V,U,yMean,normAll,plotNodes)
excludeUnresponsive=0;
iterations=20;
sigmaLGN=1.5;
p=sqrt(size(W{1},2)/2);
Iseq=images_V2_angle_stimuli(p);
numImages=size(Iseq,3);
numStages=length(W);

if nargin<6 
  plotNodes=[];
end
if nargin<4 | isempty(yMean) 
  numTrials=10;
  for stage=1:numStages
	yMean{stage}=[];
  end
  Xseq=preprocess_V1_input(Iseq,sigmaLGN);
else
  %just plot the results 
  numTrials=0;
end
if nargin<5 | isempty(normAll), normAll=0; end

%test response of each node to each pattern
for trial=1:numTrials
  presentationOrder=randperm(numImages);
  %for each test input
  for k=1:numImages
	randImNum=presentationOrder(k);
	%calculate response of network
	X=[Xseq{1}(:,:,randImNum),Xseq{2}(:,:,randImNum)];
	x{1}=X(:);
	for stage=1:numStages+1
	  y{stage}=[];
	  z{stage}=[];
	  resp{stage}=0;
	end
	for t=1:iterations
	  for stage=1:numStages
		[y{stage},e{stage},z{stage}]=dim_activation_step(...
			W{stage},x{stage},y{stage},V{stage},U{stage},z{stage+1});
		x{stage+1}=y{stage};%input to next stage equal to output from this
		resp{stage}=resp{stage}+y{stage};%sum response over all iterations
	  end
	end
	for stage=1:numStages
	  %average response of each node to the current stimulus
	  y_trial{stage}(:,randImNum)=resp{stage}./iterations;
	end
  end
  %response (averaged over time and multiple presentations) of all nodes to all
  %stimuli
  for stage=1:numStages
	yMean{stage}=mean_over_trials(trial,yMean{stage},y_trial{stage});
  end
end

%plot responses of nodes to all patterns and/or calc some statistics on the
%pattern of response in each stage

for stage=1:numStages
  stage 
  calc_stats(yMean{stage},Iseq,normAll,plotNodes,excludeUnresponsive);
end




%calculate the average similarity of the population response to different
%patters in both stages
disp('mean NCC of population vectors to all pairs of stimuli:');
for stage=1:numStages
  stage
  calc_nnc(yMean{stage})
end

disp('mean NCC of population vectors to all pairs of ANGLE stimuli:');
for stage=1:numStages
  clear y_mean_ang
  y_mean=yMean{stage};  
  for node=1:size(y_mean,1);
	y_node=flipud(reshape(y_mean(node,:),12,12)');
	y_ang=triu(y_node,1);
	y_ang=y_ang(y_ang>0);
	y_mean_ang(node,:)=y_ang(:);
  end
  calc_nnc(y_mean_ang)
end

function calc_nnc(y_mean)
similarity=0;
k=0;
for im1=1:size(y_mean,2)
  for im2=1:size(y_mean,2)
	if im1~=im2
	  k=k+1;
	  similarity=similarity+norm_cross_correl(y_mean(:,im1),y_mean(:,im2));
	end
  end
end
similarity./k

function ncc=norm_cross_correl(x,y)
ncc=sum(x.*y)./(sqrt(sum(x.^2))*sqrt(sum(y.^2)));


function calc_stats(y_mean,Iseq,normAll,plotNodes,excludeUnresponsive)
if normAll, norm=max(max(y_mean)); end
pref_dist=zeros(12,12);
nodes=1:size(y_mean,1);
k=0;
for j=nodes
  k=k+1;
  if ismember(j,plotNodes)
	figure(10+k),clf
	%plot background grid
	plot_grid
	
	%plot input stimulus with greyscale proportional to the neuron's response
	if ~normAll, norm=max(y_mean(j,:)); end
	plot_response_profile(Iseq,y_mean(j,:),norm);	
  end
  
  %calc stats for node as emplyed in V2 by Ito and Komatsu
  %1. "angle response index"
  y_node=flipud(reshape(y_mean(j,:),12,12)');
  y_hl=diag(y_node);
  y_ang=triu(y_node,1);
  max_hl=max(y_hl);
  max_ang=max(max(y_ang));
  Ia(k)=(max_ang-max_hl)./(max_ang+max_hl);
  
  %2. "peak response area"
  bw_ang=y_ang;
  bw_ang(y_ang>=0.5*max_ang)=1;
  bw_ang(y_ang<0.5*max_ang)=0;
  reglabs=bwlabel(bw_ang);
  regarea=regionprops(reglabs, 'area');
  peakarea(k)=max(cat(1,regarea.Area));
  
  %3. "widths of preferred angles"
  peak_ang=y_ang;
  peak_ang(y_ang<max_ang)=0;
  for ind=1:5
	ang(ind)=sum(diag(peak_ang,ind))+sum(diag(peak_ang,12-ind));
  end
  ang(6)=sum(diag(peak_ang,6));
  [val,prefang(k)]=max(ang);
  
  %4. "distribution of prefered angles in the angle space"
  peak_ang(y_ang==max_ang)=1;
  pref_dist=pref_dist+peak_ang;
  peaks{k}=peak_ang;
end
yMax=max(y_mean');

if excludeUnresponsive 
  yMaxMedian=median(yMax)
  excluded=0;
  k=0;
  for j=nodes
	k=k+1;
	if max(y_mean(j,:))<0.35*yMaxMedian;
	  Ia(k)=NaN;
	  pref_dist=pref_dist-peaks{k};
	  prefang(k)=NaN;
	  peakarea(k)=NaN;
	  peakarea(k)=NaN;
	  excluded=excluded+1;
	end
  end
  excluded
end
figure
subplot(2,1,1),hist(Ia),
xlabel('angle response index');ylabel('number of occurances');
subplot(2,1,2),hist(prefang,[1:6]),
xlabel('angle preference');ylabel('number of occurances');

figure
plot(prefang,Ia,'x','LineWidth',2,'MarkerSize',15),hold on, 
plot([0,7],[0,0],'k-')
disp(['mean(ARI)=',num2str(nanmean(Ia)),' median(ARI)=',num2str(nanmedian(Ia))]);
set(gca,'FontSize',22);
set(gca,'XTick',[1:6],'XTickLabel',int2str([30:30:180]'))
xlabel('angle preference','FontSize',28);
ylabel('angle response index','FontSize',28);
axis([0,7,-1,1])
plot(prefang(9),Ia(9),'ro','LineWidth',2,'MarkerSize',15),
plot(prefang(24),Ia(24),'ro','LineWidth',2,'MarkerSize',15),

figure,
hist(peakarea,[1:66]);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','EdgeColor','w');
set(gca,'FontSize',22);
xlabel('size of peak response area','FontSize',28);
ylabel('number of occurances','FontSize',28);
disp(['mean(PRA)=',num2str(nanmean(peakarea)),' median(PRA)=',num2str(nanmedian(peakarea))])

figure
plot_grid
plot_response_profile(Iseq,flipud(pref_dist),max(max(pref_dist)),1);	



function meanData=mean_over_trials(trial,meanData,newData)
fac=1/trial;
if trial==1
  meanData=fac.*newData;
else
  meanData=fac.*newData+(1-fac).*meanData;
end  


function plot_grid
axes('Position',[0,0,1,1]);
set(gca,'XTick',[1:12],'YTick',[1:12]);
for zz=1:12
  plot([0,13],[zz,zz],'k-')
  hold on
  plot([zz,zz],[0,13],'k-')
end
axis([0.5,12.5,0.5,12.5])
cmap=colormap('gray'); 
cmap=1-cmap;
colormap(cmap);
set(gcf,'PaperPosition',[1 1 12 12]);


function plot_response_profile(Iseq,y_mean,norm,noBorder)
if nargin<4, noBorder=0; end
for i=1:144,
  maxsubplot(12,12,i),
  Itmp=Iseq(:,:,i);
  Itmp=Itmp-0.5;
  Itmp=Itmp.*y_mean(i)./norm;
  %Itmp=Itmp+0.5;
  Itmp=abs(Itmp);
  imagesc(Itmp,[0,0.5]); 
  axis('equal','tight'),set(gca,'XTick',[],'YTick',[]);
  if noBorder | y_mean(i)<0.5*norm
	axis('off');
  end
end
