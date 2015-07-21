function [Y]=dim_activation_sequence(W,X,iterations,V)
[m,t]=size(X);
[n,m]=size(W);
psi=1;%5000; %need to learn using e-(1/psi)
epsilon1=0.0001; %>0.001 this becomes significant compared to y and hence
                 %produces sustained responses and more general suppression
epsilon2=100*epsilon1*psi;%this determines scaling of initial transient response

y=zeros(n,1,'single'); 
  
if nargin<4, 
  %set feedback weights equal to feedforward weights normalized by maximum value 
  %V=W./(1e-9+(max(W')'*ones(1,m)));
  V=bsxfun(@rdivide,W,(1e-9+max(W,[],2)));
end

for i=1:iterations
  %update responses replacing input with next vector in the dataset at each
  %iteration
  e=min(1,X(:,min(t,i)))./(epsilon2+(V'*y));
  y=(epsilon1+y).*(W*e);

  Y(:,i)=y;
end	

