function V1_temporal_frequency_tuning(W,V,node,best_params)
gd=best_params(1);
gw=best_params(2);
ga=best_params(3);
gp=best_params(4);
sigmaLGN=1.5;
[n,m]=size(W);
max_diam=sqrt(m/2); %calc rf diam (assuming on/off channels and square rf)

drift_rates=[1,2,4,10,20,60,180];
iterations=12;
contrast=1;
patch_diam=gd;
border=(max_diam-patch_diam)/2;

clf
j=0;
for drift_rate=drift_rates
  j=j+1;
  phase=0;
  for t=1:iterations
	I=image_square_grating(patch_diam,border,gw,ga,phase+gp,contrast);
	[a,b]=size(I);
	x=preprocess_V1_input(I,sigmaLGN);
	Xtmp=[x{1},x{2}];X(:,t)=Xtmp(:);
	phase=phase+drift_rate;
  end
  %plot original image
  maxsubplot(2,length(drift_rates),j),
  imagesc(I,[0,1]);
  axis('equal','tight'), set(gca,'XTick',[],'YTick',[],'FontSize',11);
  drawnow;
  
  %perform competition
  Y=dim_activation_sequence(W,X,iterations,V);
  sc(j)=mean(Y(node,:));
end

figure(2),clf
drift_rates=drift_rates./360; %convert to cycles / iteration
subplot(3,2,[4,6])
semilogx(drift_rates,sc,'r-o','LineWidth',4,'MarkerSize',12,'MarkerFaceColor','w');
axis([min(drift_rates)./2,max(drift_rates).*2,0,2]);
set(gca,'XTick',[0.005,0.05,0.5],'YTick',[0:1:7],'FontSize',20);
set(gca,'XTickLabel',[0.005,0.05,0.5]);
xlabel('Drift Rate (cycles/iteration)'),ylabel('Response')

