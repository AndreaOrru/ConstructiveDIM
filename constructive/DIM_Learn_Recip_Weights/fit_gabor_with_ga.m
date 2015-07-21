function [best_fit,best_fit_params]=fit_gabor_with_ga(W,shape,sigmaLGN,best_fit_params,remove_poor_fits)
[n,m]=size(W);  
if m==2*prod(shape)
  onoff=1;
  p=sqrt(m/2);
else
  onoff=0;
  p=sqrt(m);
end  
if nargin>3
  noga=1;
else
  noga=0;
end
if nargin<5
  remove_poor_fits=0;
end
global w;
global w_sum_of_squares;
global bounds;
figoffset=9;
figcompact=0;
if figcompact, fontscale=0.35; else, fontscale=1; end

% Termination Operators
termFns = 'maxGenTerm';
termOps = [10000]; % num Generations
% Evaluation Function
evalFn = 'diff_gabor';

% Bounds on the variables
halfwidth=ceil(p/2);
width=p;
bounds = [-halfwidth,halfwidth;%x coord of centre
		  -halfwidth,halfwidth;%y coord of centre
		  0,width;              %width
		  0,width;              %length
		  0,180;                %orientation
		  0,0.5;                %frequency
		  -180,180;             %phase
		  0,1]                  %amplitude
numParams=8;

if onoff
  RFrecon=reconstruct_V1RF(W,[p,p],sigmaLGN);
end
nodes=1:n;
figure(figoffset+1),clf
[plotRows,plotCols]=highest_integer_factors(n);
if figcompact, plotRows=plotRows*2; end
for j=nodes
  fprintf(1,'.%i.',j); 
  if onoff
	w=reshape(RFrecon(j,1:m/2)-RFrecon(j,m/2+1:m),p,p);
  else
	w=reshape(W(j,:),p,p);
  end
  w_sum_of_squares=sum(sum(w.^2));
  
  if ~noga
	[params endPop bestPop trace]=ga(bounds,evalFn,[],[],[],termFns,termOps);
	best_fit_params(j,:)=params;
	best_fit(j)=-params(numParams+1);
  else
	%recalculate fit using current method
	[tmp_params,tmp_diff]=diff_gabor(best_fit_params(j,1:numParams));
	best_fit(j)=-tmp_diff;
  end

  maxsubplot(plotRows,plotCols,j),
  w_fit=gabor_offcentre_interp_params(best_fit_params(j,1:numParams),p);
  lim=max(1e-9,0.95.*max(max(abs(w_fit))));
  imagesc(w_fit,[-lim,lim]);
  axis('equal','tight'); set(gca,'XTick',[],'YTick',[]);
  drawnow;
end
cmap=colormap('gray');
cmap=1-cmap;
colormap(cmap);
set(gcf,'PaperPosition',[1 1 plotCols plotRows]);


%summary of fit performance
if figcompact, maxsubplot(3,3,4), else, figure(figoffset+2),clf, end
res=[mean(best_fit),median(best_fit),max(best_fit),min(best_fit)]
hist(best_fit,[0.025:0.05:max(best_fit)]);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','EdgeColor','w');
%title(num2str(res));
set(gca,'FontSize',22*fontscale);axis('square')
xlabel('NMSE','FontSize',28*fontscale);
ylabel('number of neurons','FontSize',28*fontscale)
if figcompact, title(num2str(res)); end


%remove poor fits
if remove_poor_fits
  poor_fit=find(best_fit>2*mean(best_fit))
  length(poor_fit)
  best_fit_params(poor_fit,:)=[];
  best_fit(poor_fit)=[];
  nodes=nodes(1:n-length(poor_fit));
end

%distribution of normalised width/length
if figcompact, maxsubplot(3,3,5), else, figure(figoffset+3),clf, end
freq=best_fit_params(:,6);
normW=best_fit_params(:,3).*freq; % sigma_x*f
normL=best_fit_params(:,4).*freq; % sigma_y*f
plot(normW,normL,'bx','LineWidth',2,'MarkerSize',15*fontscale);
axis([0,2,0,2]);axis('square')
set(gca,'FontSize',22*fontscale);
xlabel('f \sigma_x','FontSize',28*fontscale);
ylabel('f \sigma_y','FontSize',28*fontscale)
if exist('ringach_rf_database.mat','file')
  load('ringach_rf_database.mat');
  hold on
  plot(db.nx,db.ny,'ro','LineWidth',1,'MarkerSize',10*fontscale);
end  

%distribution of phase
if figcompact, maxsubplot(3,3,6), else, figure(figoffset+4),clf, end
phase=best_fit_params(:,7);
comphase=abs(cos(phase))+i.*abs(sin(phase));
argcomphase=atan(imag(comphase)./real(comphase));
hist(argcomphase./pi,[0.25/6:0.25/3:0.5]);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','EdgeColor','w');
set(gca,'FontSize',22*fontscale);axis('square')
set(gca,'XTick',[0]);
text(0.25,-0.8,'\pi/4','VerticalAlignment','top','HorizontalAlignment','center','FontSize',22*fontscale)
text(0.5,-0.8,'\pi/2','VerticalAlignment','top','HorizontalAlignment','center','FontSize',22*fontscale)
xlabel('phase','FontSize',28*fontscale);
ylabel('number of neurons','FontSize',28*fontscale)

%distribution of orientation and frequency
if figcompact, maxsubplot(3,3,7), else, figure(figoffset+5),clf, end
orient=best_fit_params(:,5);
set(gca,'FontSize',20*fontscale);
polar(orient*pi/180,freq,'bx')
set( findobj(gca, 'Type', 'line'), 'LineWidth',2,'MarkerSize',12*fontscale);
axis([-0.3,0.3,0,0.2])
set(gca,'XTick',[0]);
xlabel('spatial frequency (cycles/pixel)','FontSize',24*fontscale,'VerticalAlignment','cap');
text(0,-0.006,'0','VerticalAlignment','top','HorizontalAlignment','center','FontSize',20*fontscale)
text(0.1,-0.0060,'0.1','VerticalAlignment','top','HorizontalAlignment','center','FontSize',20*fontscale)
text(-0.1,-0.0060,'0.1','VerticalAlignment','top','HorizontalAlignment','center','FontSize',20*fontscale)
text(0.2,-0.0060,'0.2','VerticalAlignment','top','HorizontalAlignment','center','FontSize',20*fontscale)
text(-0.2,-0.0060,'0.2','VerticalAlignment','top','HorizontalAlignment','center','FontSize',20*fontscale)
text(0.175,0.175,'\leftarrow ','FontSize',24*fontscale,'VerticalAlignment','top','HorizontalAlignment','center','Rotation',-45);
text(0.175,0.175,'(degrees)','FontSize',24*fontscale,'VerticalAlignment','middle','HorizontalAlignment','center','Rotation',-45);
text(0.185,0.185,'orientation','FontSize',24*fontscale,'VerticalAlignment','bottom','HorizontalAlignment','center','Rotation',-45);

%frequency distribution
if figcompact, maxsubplot(3,3,8), else, figure(figoffset+6),clf, subplot(2,1,1),end
hist(freq)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','EdgeColor','w');
set(gca,'FontSize',22*fontscale);
xlabel('frequency','FontSize',28*fontscale);
ylabel('number of neurons','FontSize',28*fontscale)

%orientation distribution
if figcompact, maxsubplot(3,3,9), else, subplot(2,1,2), end
binwidth=22.5;
%nn=hist(rem(orient,180-0.5*binwidth),[0:binwidth:180]);
hist(orient,[binwidth/2:binwidth:180]);
axval=axis;
axis([0,180,0,axval(4)])
set(gca,'XTick',[0:binwidth:180]);
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','EdgeColor','w');
set(gca,'XTick',[0:2*binwidth:180]);
set(gca,'FontSize',22*fontscale);
xlabel('orientation','FontSize',28*fontscale);
ylabel('number of neurons','FontSize',28*fontscale)

if figcompact, set(gcf,'PaperPosition',[0.7 0.7 19.5 28]); else
  figure(figoffset+7),clf,
  subplot(1,2,1)
  for j=nodes, plot(normW(j),normL(j),'x','color',[1,1,1].*(1-best_fit_params(j,8)./max(best_fit_params(:,8)))); hold on, end
  title('scaled by amplitude')
  subplot(1,2,2)
  for j=nodes, plot(normW(j),normL(j),'x','color',[1,1,1].*(best_fit(j)./max(best_fit))); hold on, end
  title('scaled by fit')
  figure(figoffset+8),clf,
  for p=1:8, subplot(2,4,p),plot(best_fit_params(:,p)); end
  subplot(2,4,1), title('x centre');
  subplot(2,4,2), title('y centre');
  subplot(2,4,3), title('width');
  subplot(2,4,4), title('length');
  subplot(2,4,5), title('orientation');
  subplot(2,4,6), title('frequency');
  subplot(2,4,7), title('phase');
  subplot(2,4,8), title('amplitude');
end
