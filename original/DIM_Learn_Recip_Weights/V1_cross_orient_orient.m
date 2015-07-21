function V1_cross_orient_orient(W,V,node,best_params)
gd=best_params(1);
gw=best_params(2);
ga=best_params(3);
gp=best_params(4);
sigmaLGN=1.5;
[n,m]=size(W);
max_diam=sqrt(m/2); %calc rf diam (assuming on/off channels and square rf)

grating_angles=[-90:22.5:90];
contrast=0.5;
iterations=12;
patch_diam=gd;
border=(max_diam-patch_diam)/2;

clf
j=0;
for test=1:2
  j=j+1;
  i=0;
  for grating_angle=grating_angles
	i=i+1;
	fprintf(1,'.%i.',i); 
	if test==1 %cross-orientation simulus
	  I=image_cross_orientation_sine(max_diam,gw,gw,ga,grating_angle,...
									 gp,gp,contrast,contrast);
	else %orientation tuning stimulus
	  I=image_square_grating(max_diam,0,gw,grating_angle+ga,gp,contrast*2); 
	end
	[a,b]=size(I);
	I(1:border,:)=0;I(a-border+1:max_diam,:)=0;
	I(:,1:border)=0;I(:,b-border+1:max_diam)=0;
	x=preprocess_V1_input(I,sigmaLGN);
	X=[x{1},x{2}];X=X(:);

	%plot original image
	maxsubplot(2,length(grating_angles),(test-1)*length(grating_angles)+i),
	imagesc(I,[0,1]);
	axis('equal','tight'), set(gca,'XTick',[],'YTick',[],'FontSize',11);
	drawnow;
	
	%perform competition
	Y=dim_activation_sequence(W,X,iterations,V);
	sc(j,i)=mean(Y(node,:));
  end
end

figure,clf
subplot(3,2,[4,6])
plot(grating_angles,sc(1,:),'r-o','LineWidth',4,'MarkerSize',12,'MarkerFaceColor','w');
hold on
plot(grating_angles,sc(2,:),'b-s','LineWidth',4,'MarkerSize',12,'MarkerFaceColor','w');
axis([-100,100,0,2])
set(gca,'XTick',[-100,0,100],'YTick',[0:1:7],'FontSize',20);
xlabel('Orientation (degrees)'),ylabel('Response')

