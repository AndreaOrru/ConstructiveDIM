function X=pattern_bars_test(p,gen)
%function X=pattern_bars_test(p,gen)

%create all possible pxp pixel images containing one bar of the defined type

switch gen

 case {'std','stdlinear','onebar','oneorient','twobars','threebars','fourbars','fivebars','sixbars','sevenbars'}
  for l=1:2*p
	x=zeros(p,p);
	if(l<=p)                 %horizontal line - activate a row
	  x(l,:)=1;
	else                     %vertical line - activate a column
	  x(:,l-p)=1;
	end
	X(:,l)=x(:);
  end
  
 case 'doublewidth'
  k=0;
  for l=1:2*p
	k=k+1;
	x=zeros(p*2,p*2);
	if(l<=p)               %horizontal line - activate a row
	  x(l*2-1:l*2,:)=1;
	else                     %vertical line - activate a column
	  x(:,(l-p)*2-1:(l-p)*2)=1;
	end
	X(:,k)=x(:);
  end
  
 case 'quadwidth'
  disp('4 pixel wide bar patterns (no overlap)');
  k=0;
  for l=1:2*p
	k=k+1;
	x=zeros(p*4,p*4);
	if(l<=p)               %horizontal line - activate a row
	  x(l*4-3:l*4,:)=1;
	else                     %vertical line - activate a column
	  x(:,(l-p)*4-3:(l-p)*4)=1;
	end
	X(:,k)=x(:);
  end
  
 case 'doubleoverlap'
  k=0;
  for l=[1:p-1,p+1:2*p-1]
	k=k+1;
	x=zeros(p,p);
	if(l<=p)               %horizontal line - activate a row
	  x(l:l+1,:)=1;
	elseif (l>p) %vertical line - activate a column
	  x(:,l-p:l+1-p)=1;
	end
	X(:,k)=x(:);
  end
  
 case 'unequal'
  if p~=16, disp('ERROR: image size of 16 expected for unequal bars problem');end
  k=0;
  for l=1:7  %horizontal= 7x 1-pixel-wide plus 1x 9-pixel-wide
	k=k+1;
	x=zeros(p,p);
	x(l,:)=1;
	X(:,k)=x(:);
  end
  k=k+1;
  x=zeros(p,p);
  x(8:16,:)=1; 
  X(:,k)=x(:);
  
  for l=1:7 % vertical = 7x 1-pixel-wide plus 1x 9-pixel-wide
	k=k+1;
	x=zeros(p,p);
	x(:,l)=1;
	X(:,k)=x(:);
  end
  k=k+1;
  x=zeros(p,p);
  x(:,8:16)=1; 
  X(:,k)=x(:);

 otherwise
  disp('ERROR: no bars problem defined');
end

