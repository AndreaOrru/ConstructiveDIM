function V1_size_tuning(W,V,node,best_params)
gd=best_params(1);
gw=best_params(2);
ga=best_params(3);
gp=best_params(4);
sigmaLGN=1.5;
[n,m]=size(W);
max_diam=sqrt(m/2); %calc rf diam (assuming on/off channels and square rf)

grating_diams=[3:2:max_diam]
iterations=12;
contrast=1;

clf
j=0;
for test=1:2
  j=j+1;
  i=0;
  for grating_diam=grating_diams
	i=i+1;
	fprintf(1,'.%i.',i); 
	if test==1 %a grating
	  I=image_contextual_surround(grating_diam,(max_diam-grating_diam)/2,0,...
								  gw,gw,ga,ga,gp,gp,contrast,0);
	else %an annulus
	  I=image_contextual_surround(0,grating_diam/2,(max_diam-grating_diam)/2,...
								  gw,gw,ga,ga,gp,gp,0,contrast);
	end
	[a,b]=size(I);
	x=preprocess_V1_input(I,sigmaLGN);
	X=[x{1},x{2}];X=X(:);

	%plot original image
	maxsubplot(3,length(grating_diams),i),
	imagesc(I(:,:,1),[0,1]);
	axis('equal','tight'), set(gca,'XTick',[],'YTick',[],'FontSize',11);
	drawnow;
	
	%perform competition
	Y=dim_activation_sequence(W,X,iterations,V);
	sc(j,i)=mean(Y(node,:));

	y=mean(Y,2);
	maxsubplot(3,length(grating_diams),i+2*length(grating_diams)),
	[plotrows,plotcols]=highest_integer_factors(length(y));
	imagesc(reshape(y,plotrows,plotcols),[0,1]), 
	axis('equal','tight'), set(gca,'XTick',[],'YTick',[],'FontSize',11);
	drawnow;
  end
end

clf
subplot(3,2,[4,6])
plot(grating_diams,sc(1,:),'r-o','LineWidth',4,'MarkerSize',12,'MarkerFaceColor','r');
hold on
plot(grating_diams,sc(2,:),'b-o','LineWidth',4,'MarkerSize',12,'MarkerFaceColor','w');
axis([0,25,0,2])
set(gca,'XTick',[5:5:30],'YTick',[0:1:7],'FontSize',20);
xlabel('Diameter (pixels)'),ylabel('Response')

