function V1_orientation_tuning_contrast(W,V,node,best_params)
gd=best_params(1);
gw=best_params(2);
ga=best_params(3);
gp=best_params(4);
sigmaLGN=1.5;
[n,m]=size(W);
max_diam=sqrt(m/2); %calc rf diam (assuming on/off channels and square rf)

grating_angles=[-45:7.5:45];
contrasts=[0.25,0.5,1];
iterations=12;
patch_diam=gd;
border=(max_diam-patch_diam)/2;

clf
j=0;
for contrast=contrasts
  j=j+1;
  i=0;
  for grating_angle=grating_angles
	i=i+1;
	fprintf(1,'.%i.',i); 
	I=image_circular_grating(patch_diam,border,gw,grating_angle+ga,gp,contrast); 
	[a,b]=size(I);
	x=preprocess_V1_input(I,sigmaLGN);
	X=[x{1},x{2}];X=X(:);

	%plot original image
	maxsubplot(2,length(grating_angles),i),
	imagesc(I,[0,1]);
	axis('equal','tight'), set(gca,'XTick',[],'YTick',[],'FontSize',11);
	drawnow;
	
	%perform competition
	Y=dim_activation_sequence(W,X,iterations,V);
	sc(j,i)=mean(Y(node,:));

	y=mean(Y,2);
	maxsubplot(2,length(grating_angles),i+length(grating_angles)),
	[plotrows,plotcols]=highest_integer_factors(length(y));
	imagesc(reshape(y,plotrows,plotcols),[0,1]), 
	axis('equal','tight'), set(gca,'XTick',[],'YTick',[],'FontSize',11);
	drawnow;		
  end
end

clf
subplot(3,2,[4,6])
plot(grating_angles,sc(1,:),'r-o','LineWidth',1,'MarkerSize',8,'MarkerFaceColor','r');
hold on
plot(grating_angles,sc(2,:),'r-o','LineWidth',3,'MarkerSize',8,'MarkerFaceColor','r');
plot(grating_angles,sc(3,:),'r-o','LineWidth',5,'MarkerSize',8,'MarkerFaceColor','r');
axis([-50,50,0,2])
set(gca,'XTick',[-50:50:50],'YTick',[0:0.5:7],'FontSize',20);
xlabel('Orientation (degrees)'),ylabel('Response')

