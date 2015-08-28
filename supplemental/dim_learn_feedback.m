function [U]=dim_learn_feedback(U,y,x,beta)
if nargin<4, beta=0.005; end

e=x./(1e-2+(U'*y));
delta=beta.*(y*(e'-1));

%update weights
U=U.*(1 + delta);
U(find(U<0))=0; 

