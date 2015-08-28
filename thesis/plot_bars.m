function [nrepanycomplete]=plot_bars(gen,weights,label_plots,scale,scale_bar,noplot)
%function [nrep]=plot_bars(gen,weights,label_plots,scale,scale_bar)
[n,m]=size(weights);
p=sqrt(m);
thres=2;
if nargin<3, label_plots=1; end
if nargin<4 | isempty(scale), scale=max(max(weights))*0.9; end
if nargin<5, scale_bar=0; end
if nargin<6, noplot=0; end
[plotRows,plotCols]=highest_integer_factors(n);
clf

switch gen
 case 'triplediags'
  diags=-7:3:7;
  lines=2*(p+length(diags));
 case 'dbldiags'
  diags=-ceil(7/2):2:ceil(7/2);
  lines=2*(p+length(diags));
 case 'diags'
  diags=-3:3;
  lines=2*(p+length(diags));
 case 'doublewidth'
  lines=2*(p/2);
 case 'quadwidth'
  lines=2*(p/4);
 case 'doubleoverlap'
  lines=2*(p-1);
  thres=1.5;
 case 'unequal'
  lines=16;
  thres=1.5;
 otherwise
  lines=2*p;
end
representedcomplete=zeros(1,lines);

for j=1:n
  %test and plot weights corresponding to one node
  w=reshape(weights(j,:),p,p);
  if ~noplot
	if scale_bar
	  maxsubplot(plotRows+scale_bar,plotCols,j+plotCols),
	else
	  subplot(plotRows,plotCols,j),
	end
	hinton_plot(flipud(w'),scale,3,1,1);
  end
  
  %calculate minimum weight corresponding to all possible components
  rfmin=[min(w), min(w')];
  switch gen
   case 'triplediags'
	for k=diags
	  rfmin=[rfmin, min([diag(w,k);diag(w,k+1);diag(w,k+2)]), min([diag(fliplr(w),k);diag(fliplr(w),k+1);diag(fliplr(w),k+2)])];	
	end
   case 'dbldiags'
	for k=diags
	  rfmin=[rfmin, min([diag(w,k);diag(w,k+1)]), min([diag(fliplr(w),k);diag(fliplr(w),k+1)])];	
	end
   case 'diags'
	for k=diags
	  rfmin=[rfmin, min(diag(w,k)), min(diag(fliplr(w),k))];
	end 
   case 'doublewidth'
	k=0;
	for i=1:2:p
	  k=k+1;
	  twobarmin(k)=min([rfmin(i),rfmin(i+1)]);
	  twobarmin(k+p/2)=min([rfmin(i+p),rfmin(i+p+1)]);
	end
	rfmin=twobarmin;
   case 'quadwidth'
	k=0;
	for i=1:4:p
	  k=k+1;
	  fourbarmin(k)=min([rfmin(i),rfmin(i+1),rfmin(i+2),rfmin(i+3)]);
	  fourbarmin(k+p/4)=min([rfmin(i+p),rfmin(i+p+1),rfmin(i+p+2),rfmin(i+p+3)]);
	end
	rfmin=fourbarmin;   
   case 'doubleoverlap'
	for i=1:p-1
	  twobarmin(i)=min([rfmin(i),rfmin(i+1)]);
	  twobarmin(i+p-1)=min([rfmin(i+p),rfmin(i+p+1)]);
	end
	rfmin=twobarmin;
   case 'unequal'
	rfmin=[min(w(1:7,:)'),min(min(w(8:16,:))),min(w(:,1:7)),min(min(w(:,8:16)))];
  end
  
  
  %calculate maximum weight corresponding to all possible components
  rfmag=[sum(w), sum(w')];
  switch gen
   case 'triplediags'
	for k=diags
	  rfmag=[rfmag, sum([diag(w,k);diag(w,k+1);diag(w,k+2)]), sum([diag(fliplr(w),k);diag(fliplr(w),k+1);diag(fliplr(w),k+2)])];
	end 
   case 'dbldiags'
	for k=diags
	  rfmag=[rfmag, sum([diag(w,k);diag(w,k+1)]), sum([diag(fliplr(w),k);diag(fliplr(w),k+1)])];
	end 
   case 'diags'
	for k=diags
	  rfmag=[rfmag, sum(diag(w,k)), sum(diag(fliplr(w),k))];
	end 
   case 'doublewidth'
	k=0;
	for i=1:2:p
	  k=k+1;
	  twobarmag(k)=rfmag(i)+rfmag(i+1);
	  twobarmag(k+p/2)=rfmag(i+p)+rfmag(i+p+1);
	end
	rfmag=twobarmag;
   case 'quadwidth'
	k=0;
	for i=1:4:p
	  k=k+1;
	  fourbarmag(k)=rfmag(i)+rfmag(i+1)+rfmag(i+2)+rfmag(i+3);
	  fourbarmag(k+p/4)=rfmag(i+p)+rfmag(i+p+1)+rfmag(i+p+2)+rfmag(i+p+3);
	end
	rfmag=fourbarmag;
   case 'doubleoverlap'
	for i=1:p-1
	  twobarmag(i)=rfmag(i)+rfmag(i+1);
	  twobarmag(i+p-1)=rfmag(i+p)+rfmag(i+p+1);
	end
	rfmag=twobarmag;
   case 'unequal'
	rfmag=[sum(w(1:7,:)'),sum(sum(w(8:16,:)))/9,sum(w(:,1:7)),sum(sum(w(:,8:16)))/9];
  end
  [rfmax,lpref]=max(rfmag);
  rfmag(lpref)=0; %so that max(rfmag) will now be for the 2nd best
                  %represented component

  %decide any component meets criteria for being represented
  if rfmax>thres*max(rfmag) & rfmin(lpref)>mean(mean(w))
	representedcomplete(lpref)=representedcomplete(lpref)+1;
	if label_plots
	  if representedcomplete(lpref)>1, 
		text(1,0.25,['(',int2str(lpref),')']);
	  else
		text(1,0.25,int2str(lpref));
	  end	
	end
  end
end
nrepanycomplete=length(find(representedcomplete>0));
disp(['weigths represent ', int2str(nrepanycomplete), ' patterns ']);
norep=find(representedcomplete==0);
if length(norep>1) disp(['FAILED to represent pattern = ',int2str(norep)]); end

if scale_bar & ~noplot
  maxsubplot(plotRows+scale_bar,1,1)
  plot_bar([0,scale],'t');
  set(gcf,'PaperPosition',[1 1 6 5]);
end

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
