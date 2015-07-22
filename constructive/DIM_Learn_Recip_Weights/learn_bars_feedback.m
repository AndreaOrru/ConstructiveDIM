function [X,W,V,U]=learn_bars_feedback(gen,W,V,U)
%DEFINE NETWORK PARAMETERS
beta=0.005;              %learning rate
iterations=200;          %number of iterations to calculate y (for each input)
if nargin<1
  gen='std';             %type of bars pattern
end
p=5;                     %length of one side of input image/number of bars at
                         %each orientation
n=2;                     %number of nodes
m=p*p;                   %number of inputs
epochs=20;               %number of training epochs
cycs=1000;               %number of training cycles per epoch
patterns=400;            %number of training patterns in training set
noise=0.1;               %amount of noise to add to each training pattern
continuousLearning=0;    %learn at every iteration, or using steady-state responses
dispresults=1;
figoffset=0;

%constructive parameters
t0 = 1;                      %time of last added neuron
window = 1;                  %window for slope calculation
tslope = 0.05;               %trigger slope
esptsh = 1.00;               %average error until exponential growth
cutavg = 0.70;               %average error to cut growing
stop   = 0;                  %boolean value to stop growing
eavgs  = zeros(1, epochs);   %average errors per epochs


%GENERATE TRAINING DATA
prob=1/p;
switch gen
 case 'doubleoverlap'
  p=p+1; m=p^2;
 case 'quadwidth'
  m=(p*4)^2; 
 case 'doublewidth'
  m=(p*2)^2; 
  n=n*4
 case 'unequal'
  p=16;
  m=p.^2;
  %n=n*4
end
for k=1:patterns
  X(:,k)=pattern_bars(p,prob,gen,noise);
end

%DEFINE INITIAL WEIGHTS
if nargin<2,
  [W,V,U]=weight_initialisation_random(n,m);
end
if dispresults
  figure(1+figoffset),clf, plot_bars(gen,W);
  figure(2+figoffset),clf, plot_bars(gen,V);
  figure(3+figoffset),clf, plot_bars(gen,U);
end

ymax=0;
y=[];
%TRAIN NETWORK
for t=1:epochs
  fprintf(1, 'Epoch %i, ', t);
  eavg = 0;
  
  for k=1:cycs
    %choose an input stimulus from the training set
    patternNum=fix(rand*patterns)+1; %random order
    x=X(:,patternNum);
    %OR
    %generate a new pattern at each training cycle 
    %x=pattern_bars(p,prob,gen,noise);

    if continuousLearning  
	  %calculate node activations and learn at each iteration
	  [y,e,W,V,U]=dim_activation(W,x,y,1+floor(rand*2*iterations),V,beta/iterations,U);
    else	
	  %OR calculate node activations for a set number of iterations then learn
	  [y,e]=dim_activation(W,x,y,iterations,V);
	  [W,V]=dim_learn(W,V,y,e,beta);
	  U=dim_learn_feedback(U,y,x,beta);
    end
  
    if ~isempty(e(e>0)),
      eavg = (eavg*(k-1) + mean(abs(e(e>0) - 1))) / k;
    end;
    
    ymax=max([ymax,max(y)]);  
  end
  
  fprintf(1, 'nodes: %i, error: %f\n',n,eavg);
  eavgs(t) = eavg;
  
  %show results
  if dispresults
    set(0,'CurrentFigure',1+figoffset); plot_bars(gen,W);
    set(0,'CurrentFigure',2+figoffset); plot_bars(gen,V);
    set(0,'CurrentFigure',3+figoffset); plot_bars(gen,U);
    disp([' ymax=',num2str(ymax),' wSum=',num2str(max(sum(W'))),' vSum=',...
        num2str(max(sum(V'))),' uSum=',num2str(max(sum(U')))]);
    ymax=0;
  end
  
  %check stop condition
  if eavgs(t) <= cutavg,
      stop = 1;
  end;
  
  %check growing condition
  if ~stop,
    %esponential growth
    if eavg >= esptsh,
      t0 = t;
      n = n * 2;
      [W,V,U]=weight_initialisation_random(n,m);
      y = [];
    
    %gradual growing
    elseif t - window >= t0,
      if (abs(eavgs(t) - eavgs(t - window)) / eavgs(t0)) < tslope,
        t0 = t;
        n = n + 1;
        [W,V,U]=weight_initialisation_random(n,m);
        y = [];
      end;
    end;
  end;
end
  
if dispresults
  sw=sum(W'), disp(num2str([max(sw),min(sw),max(max(W)),min(min(W))]))
  sv=sum(V'), disp(num2str([max(sv),min(sv),max(max(V)),min(min(V))]))
  su=sum(U'), disp(num2str([max(su),min(su),max(max(U)),min(min(U))]))
  disp('');  
end


