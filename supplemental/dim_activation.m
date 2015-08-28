function [y,e,W,V,U]=dim_activation(W,x,y,iterations,V,beta,U)
[n,m]=size(W);
psi=1;%5000; %need to learn using e-(1/psi)
epsilon1=0.0001; %>0.001 this becomes significant compared to y and hence
                 %produces sustained responses and more general suppression
epsilon2=100*epsilon1*psi;%this determines scaling of initial transient response

if nargin<3 || isempty(y), y=zeros(n,1,'single'); end
  
if nargin<4, iterations=25; end
if nargin<5, 
  %set feedback weights equal to feedforward weights normalized by maximum value 
  %V=W./(1e-9+(max(W')'*ones(1,m)));
  V=bsxfun(@rdivide,W,(1e-9+max(W,[],2)));
  U=V;
end

x=min(1,x);
%x=tanh(pi.*x);
for i=1:iterations
  %update responses
  e=x./(epsilon2+(V'*y));
  y=(epsilon1+y).*(W*e);

  %perform learning at every step - if required
  if nargout>2 
	[W,V]=dim_learn(W,V,y,e,beta);  
  end
  if nargout>4
	U=dim_learn_feedback(U,y,x,beta);
  end
end	

