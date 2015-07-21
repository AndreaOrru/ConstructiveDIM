function [a,b]=highest_integer_factors(x)
b=ceil(sqrt(x));
nofac=1;
b=b-1;
while b<x & nofac
  b=b+1;
  if x/b==floor(x/b)
	nofac=0;
  end	
end	
a=x/b;
	
