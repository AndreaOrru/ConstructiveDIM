function [Xp]=measure_sparsity(Xp,W,V)

%DEFINE NETWORK PARAMETERS
iterations=20            %number of iterations to calculate y (for each input)
[n,m]=size(W);
p=sqrt(m/2);
figcompact=0;

%GENERATE TRAINING DATA
sigmaLGN=1.5;
if nargin<1 | isempty(Xp)
  tests=1000;
  %load natural images
  load('IMAGES_RAW_Olshausen.mat');
  %load('IMAGES_RAW_VanHateren.mat');
  %load('/home/store/Data/Olshausen_natural_images/IMAGES_RAW.mat');
  %load('/home/store/Data//VanHateren_natural_images/IMAGES_RAW.mat');
  nI=size(IMAGESr,3);
  
  %normalise greyscale of each image 
  for k=1:nI
	I(:,:,k)=IMAGESr(:,:,k)-min(min(IMAGESr(:,:,k)));
	I(:,:,k)=I(:,:,k)./max(max(I(:,:,k)));
  end
  %convolve images with LOG filter and separate into ON and OFF channels
  X=preprocess_V1_input(I,sigmaLGN);


  %CREATE A SET OF TEST STIMULI
  disp('creating stimuli');
  for k=1:tests
	if rem(k,1000)==0, fprintf(1,'.%i.',k); end
    %choose an input stimulus
	i=randi([1,nI],1);
	Xp(:,k)=rand_patch_onoff(X{1}(:,:,i),X{2}(:,:,i),p,sigmaLGN); 
	for kk=1:k-1
	  if max(abs(Xp(:,kk)-Xp(:,k)))<1e-2
		disp('WARNING repeated patches in test set');
	  end
	end
  end
else
  [poo,tests]=size(Xp);
end

%RECORD RESPONSES TO TEST STIMULI
disp('recording responses');
%initialize response using last image patch as the input
y=zeros(n,1,'single');
y=dim_activation_profile(W,Xp(:,tests),y,iterations,V);
%TEST NETWORK
for k=1:tests
  if rem(k,1000)==0, fprintf(1,'.%i.',k); end

  %calculate node activations
  [y,Y,nmse]=dim_activation_profile(W,Xp(:,k),y,iterations,V);
  ymean=mean(Y,2)';
  Ytest(:,k)=mean(Y,2)'; %mean response over presentation time for each node
  NMSE(k)=nmse;
end
mean(NMSE)
%CALCULATE SPARSITY
%for j=1:n
%  Ytest(j,:)=Ytest(j,:)./sqrt(sum(Ytest(j,:).^2)/tests);
%end

%measure population sparseness: measure response sparsity across the
%population for each stimulus
sp_kurt=measure_sparsity_kurtosis(Ytest');
sp_RT=measure_sparsity_rolls_tovee(Ytest');
sp_Hoyer=measure_sparsity_hoyer(Ytest);

%measure lifetime sparseness: measure response sparsity across stimuli for
%each neuron (=selectivity)
sl_kurt=measure_sparsity_kurtosis(Ytest);
sl_RT=measure_sparsity_rolls_tovee(Ytest);
sl_Hoyer=measure_sparsity_hoyer(Ytest');


%PLOT RESULTS
disp(['mean kurtosis: population=',num2str(mean(sp_kurt)),...
	  ' lifetime=',num2str(mean(sl_kurt))]);
disp(['mean Rolls-Tovee: population=',num2str(mean(sp_RT)),...
	  ' lifetime=',num2str(mean(sl_RT))]);
disp(['mean Hoyer: population=',num2str(mean(sp_Hoyer)),...
	  ' lifetime=',num2str(mean(sl_Hoyer))]);

clf
if figcompact, subplot(2,3,1), else, figure(1), clf, end
plot_hist(sp_kurt,0,0.5*tests,0);
if figcompact, subplot(2,3,2), else, figure(2), clf, end
plot_hist(sp_RT,0.5,0.5*tests,0);
if figcompact, subplot(2,3,3), else, figure(3), clf, end
plot_hist(sp_Hoyer,0.5,0.5*tests,0);

if figcompact, subplot(2,3,4), else, figure(4), clf, end
plot_hist(sl_kurt,0,100,1); 
if figcompact, subplot(2,3,5), else, figure(5), clf, end
plot_hist(sl_RT,0.5,100,1); 
if figcompact, subplot(2,3,6), else, figure(6), clf, end
plot_hist(sl_Hoyer,0.5,100,1); 




function plot_hist(s,xmin,ymax,p)
step=(1-xmin)/20;
[vals,xout]=hist(s,[xmin+step:2*step:1-step]);bar(xout,vals,1); 
if max(s)>1
  hist(s)
  axis([xmin,max(s),0,ymax]);
else
  axis([xmin,1,0,ymax]);
  if max(vals)>ymax, 
	disp(['plot_hist: y-axis range too small ',num2str(max(vals))]); 
  end
end
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','EdgeColor','w');
set(gca,'FontSize',22);
if p
  xlabel('selectivity','FontSize',28);
  ylabel('number of neurons','FontSize',28);
else
  xlabel('sparseness','FontSize',28);
  ylabel('number of stimuli','FontSize',28);
end
set(gcf,'PaperPosition',[1 1 7 5]);

hold on
ms=mean(s);
if ms<=1, sigfig=2;
elseif ms<10, sigfig=3;
elseif ms<100, sigfig=3;
elseif ms<1000, sigfig=4;
end  
plot([ms,ms],[0,1000],'k-','LineWidth',3)
text(double(ms),ymax,['mean = ',num2str(ms,sigfig)],'FontSize',28,'HorizontalAlignment','center','VerticalAlignment','bottom');




function s=measure_sparsity_rolls_tovee(Y)
[n,tests]=size(Y);
s=(1-((sum(Y')/tests).^2./(sum(Y'.^2)/tests)))./(1-1/tests);

function s=measure_sparsity_hoyer(Y)
[n,tests]=size(Y);
for t=1:tests
  s(t)=(sqrt(n)-(sum(Y(:,t))/sqrt(sum(Y(:,t).^2))))/(sqrt(n)-1);
end

function s=measure_sparsity_kurtosis(Y)
[n,tests]=size(Y);
m=mean(Y');
v=var(Y');
for t=1:n
  s(t)=(1/tests).*sum( ((Y(t,:)-m(t)).^4)./(v(t).^2)) -3;
end
