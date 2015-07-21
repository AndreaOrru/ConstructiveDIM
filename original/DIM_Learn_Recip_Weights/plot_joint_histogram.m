function H=plot_joint_histogram(filter1,filter2)
%If filter1 and filter2 are vectors containing the responses of two neurons to
%many stimuli. This function plots the joint response distributuin for these two
%neurons.
numbins=15;
H=zeros(numbins);

%hist centres
top=min([max(filter1),max(filter2)]);
bot=min(min([filter1,filter2]));
if bot<0, bot=-top; else, bot=0; end
gap=(top-bot)/numbins; %gap between bin centres

minbin=Inf;
%count numer of response pairs fail in each bin
for i=1:numbins
  range1=(bot+gap/2+((i-1)*gap))+[-gap/2,gap/2];
  a=find(filter1>range1(1) & filter1<=range1(2));
  for j=1:numbins
	range2=(bot+gap/2+((j-1)*gap))+[-gap/2,gap/2];
  	b=find(filter2>range2(1) & filter2<=range2(2));
	H(j,i)=length(intersect(a,b));
  end
  %normalise columns of joint histogram
  minbin=min(minbin,max(H(:,i)));
  H(:,i)=H(:,i)./max(1e-9,max(H(:,i)));
end
minbin;
H=flipud(H);
imagesc(H);

scale=10;
axpoints=[1,ceil(numbins/2),numbins];
axpointlabels=fix([bot,mean([bot,top]),top].*scale)/scale;
set(gca,'XTick',axpoints,'YTick',axpoints,'FontSize',12);
set(gca,'XTickLabel',axpointlabels,'YTickLabel',fliplr(axpointlabels));
axis('equal','tight')
drawnow;
