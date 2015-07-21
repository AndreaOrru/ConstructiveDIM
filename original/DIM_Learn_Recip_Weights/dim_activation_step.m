function [y,e,z,W,V,U]=dim_activation_step(W,x,y,V,U,A,beta)
[n,m]=size(W);
psi=1;%5000; %need to learn using e-(1/psi)
epsilon1=0.0001; %>0.001 this becomes significant compared to y and hence
                 %produces sustained responses and more general suppression
epsilon2=100*epsilon1*psi;%this determines scaling of initial transient response
eta=1;

if nargin<3 | isempty(y), y=zeros(n,1,'single'); end
  
if nargin<4, 
  %set feedback weights equal to feedforward weights normalized by maximum value 
  %V=W./(1e-9+(max(W')'*ones(1,m)));
  V=bsxfun(@rdivide,W,(1e-9+max(W,[],2)));
end
if nargin<6 | isempty(A)
  A=zeros(size(y));
end

%update responses
e=min(1,x)./(epsilon2+(V'*y));
y=(epsilon1+y).*(W*e).*(1+eta.*min(1,A));
z=U'*y;    %feedback to preceding processing stage

%perform learning at every step - if required
if nargout>3
  [W,V]=dim_learn(W,V,y,e,beta);  
end
if nargout>5
  U=dim_learn_feedback(U,y,x,beta);
end
