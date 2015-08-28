function xt=Heaviside(x)

xt=x; 
xt(x==0)=0.5;
xt(x<0)=0; 
xt(x>0)=1; 

