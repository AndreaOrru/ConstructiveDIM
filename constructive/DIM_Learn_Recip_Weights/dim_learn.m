function [W,V]=dim_learn(W,V,y,e,beta)
if nargin<5, beta=0.005; end

%update forward weights
delta=beta.*(y*(e'-1));
W=W.*(1 + delta);
W(W<0)=0; 

if nargout>1
  %update feedback weights
  scale=beta.*Heaviside(y-1)*ones(size(e'));
  
  V=V.*(1 + delta+scale);
  V(V<0)=0; 
end
