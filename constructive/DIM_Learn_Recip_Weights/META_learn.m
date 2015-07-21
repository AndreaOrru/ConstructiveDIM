clear
RandStream.setDefaultStream(RandStream.create('mt19937ar','seed',0));
figure(1), figure(2), figure(3), figure(4)

trials=25;
squares=1;
if squares
  s=4;
  Xtest=pattern_squares_test(6,s);
else
  gen='std';%'doubleoverlap';%'sixbars';%'unequal';%'fivebars';%'quadwidth';%'doublewidth';%
  Xtest=pattern_bars_test(5,gen);
  hierarchy=0;
end

for k=1:trials
  disp(['trial ',int2str(k)]); disp(' ');
  
  if squares
	[X,W,V,U]=learn_squares_feedback(s);
	set(0,'CurrentFigure',1); repW(k)=plot_squares(s,W); 
	set(0,'CurrentFigure',2); repV(k)=plot_squares(s,V); 
	set(0,'CurrentFigure',3); repU(k)=plot_squares(s,U); 
	set(0,'CurrentFigure',4); respAcc(k)=test_response(Xtest,W,V);
  else
	if hierarchy
	  [X,W,V,U,Wh,Vh,Uh]=learn_bars_hierarchy(gen);
	else
	  [X,W,V,U]=learn_bars_feedback(gen);
	end
	set(0,'CurrentFigure',1); repW(k)=plot_bars(gen,W); 
	set(0,'CurrentFigure',2); repV(k)=plot_bars(gen,V);
	set(0,'CurrentFigure',3); repU(k)=plot_bars(gen,U);
	if hierarchy
	  set(0,'CurrentFigure',4); respAcc(k)=test_response(Xtest,Wh,Vh,Uh);
	else
	  set(0,'CurrentFigure',4); respAcc(k)=test_response(Xtest,W,V);
	end
  end
end
sw=sum(W'), disp(num2str([max(sw),min(sw),max(max(W)),min(min(W))]))
sv=sum(V'), disp(num2str([max(sv),min(sv),max(max(V)),min(min(V))]))
su=sum(U'), disp(num2str([max(su),min(su),max(max(U)),min(min(U))]))
disp(' ');
disp([num2str(mean(repW)),'  ',num2str(max(repW)),'  ',num2str(min(repW))])
disp([num2str(mean(repV)),'  ',num2str(max(repV)),'  ',num2str(min(repV))])
disp([num2str(mean(repU)),'  ',num2str(max(repU)),'  ',num2str(min(repU))])
disp([num2str(mean(respAcc)),'  ',num2str(max(respAcc)),'  ',num2str(min(respAcc))])
reliability=length(find(respAcc==1))./trials