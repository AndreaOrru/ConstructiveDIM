function x=pattern_bars(p,prob,gen,noise)
%function x=pattern_bars(p,prob,gen,noise)
%
%create a pxp pixel image in which horizontal and vertical bars
%are randomly active with probability 'prob'

x=zeros(p,p,'single');

switch gen

 case 'std'
  %disp('standard bars');
  for l=1:2*p
	if (rand<prob)
	  if(l<=p)                 %horizontal line - activate a row
		x(l,:)=1;
	  else                     %vertical line - activate a column
		x(:,l-p)=1;
	  end
    end
  end
  
 case 'diags'
  for l=1:2*p
	if (rand<prob)
	  if(l<=p)                 %horizontal line - activate a row
		x(l,:)=1;
	  else                     %vertical line - activate a column
		x(:,l-p)=1;
	  end
    end
  end
  dl=3;
  for d=-dl:dl
	if (rand<0.5*prob)
	  dm=diag(ones(1,p-abs(d)),d);         %diagonal - backward sloping
	  x=max(x,dm);
	end
  end	
  for d=-dl:dl
	if (rand<0.5*prob)
	  dm=fliplr(diag(ones(1,p-abs(d)),d)); %diagonal - forward sloping
	  x=max(x,dm);
	end
  end	
 
 case 'dbldiags'
  for l=1:2*p
	if (rand<prob)
	  if(l<=p)                 %horizontal line - activate a row
		x(l,:)=1;
	  else                     %vertical line - activate a column
		x(:,l-p)=1;
	  end
    end
  end
  num=7;
  for d=-ceil(num/2):2:ceil(num/2)
	if (rand<0.5*prob)
	  dm1=diag(ones(1,p-abs(d)),d);         %diagonal - backward sloping
	  x=max(x,dm1);
	  dm2=diag(ones(1,p-abs(d+1)),d+1);         %diagonal - backward sloping
	  x=max(x,dm2);
	end
  end	
  for d=-ceil(num/2):2:ceil(num/2)
	if (rand<0.5*prob)
	  dm1=fliplr(diag(ones(1,p-abs(d)),d)); %diagonal - forward sloping
	  x=max(x,dm1);
	  dm2=fliplr(diag(ones(1,p-abs(d+1)),d+1)); %diagonal - forward sloping
	  x=max(x,dm2);
	end
  end	
	
 case 'triplediags'
  for l=1:2*p
	if (rand<prob)
	  if(l<=p)                 %horizontal line - activate a row
		x(l,:)=1;
	  else                     %vertical line - activate a column
		x(:,l-p)=1;
	  end
    end
  end

  for d=-7:3:7
	if (rand<0.25*prob)
	  for dd=0:2
		dm=diag(ones(1,p-abs(d+dd)),d+dd);         %diagonal - backward sloping
		x=max(x,dm);
	  end	  
	end
  end	
  for d=-7:3:7
	if (rand<0.25*prob)
	  for dd=0:2
		dm=fliplr(diag(ones(1,p-abs(d+dd)),d+dd)); %diagonal - forward sloping
		x=max(x,dm);
	  end
	end
  end	
 
 case 'stdlinear'
  %disp('linear bars');
  for l=1:2*p
	if (rand<prob)
	  if(l<=p)                 %horizontal line - activate a row
		x(l,:)=x(l,:)+1;
	  else                     %vertical line - activate a column
		x(:,l-p)=x(:,l-p)+1;
	  end
    end
  end
  
 case 'onebar'
  %disp('one bar patterns');
  l=fix(rand*2*p)+1;
  if(l<=p)                 %horizontal line - activate a row
    x(l,:)=1;
  else                     %vertical line - activate a column
    x(:,l-p)=1;
  end
  
 case 'oneorient'
  %disp('one orientation bars');
  orientation=round(rand);
  for l=1:2*p
    if (rand<prob);
	  if(l<=p & orientation==0)           %horizontal line - activate a row
        x(l,:)=1;
	  elseif(l>p & orientation==1)        %vertical line - activate a column
	    x(:,l-p)=1;
	  end
    end
  end
  
 case 'horizonly'
  orientation=0;
  for l=1:2*p
    if (rand<prob);
	  if(l<=p & orientation==0)           %horizontal line - activate a row
        x(l,:)=1;
	  elseif(l>p & orientation==1)        %vertical line - activate a column
	    x(:,l-p)=1;
	  end
    end
  end
 
 case 'vertonly'
  orientation=1;
  for l=1:2*p
    if (rand<prob);
	  if(l<=p & orientation==0)           %horizontal line - activate a row
        x(l,:)=1;
	  elseif(l>p & orientation==1)        %vertical line - activate a column
	    x(:,l-p)=1;
	  end
    end
  end
 
 case 'twobars'
  %disp('two bar patterns');
  x=fixedbars(x,p,2);
  
 case 'threebars'
  %disp('three bar patterns');
  x=fixedbars(x,p,3);
  
 case 'fourbars'
  %disp('four bar patterns');
  x=fixedbars(x,p,4);
  
 case 'fivebars'
  %disp('five bar patterns');
  x=fixedbars(x,p,5);
  
 case 'sixbars'
  %disp('six bar patterns');
  x=fixedbars(x,p,6);
  
 case 'sevenbars'
  %disp('seven bar patterns');
  x=fixedbars(x,p,7);
  
 case 'doublewidth'
  %disp('double width bar patterns (no overlap)');
  x=zeros(p*2,p*2);
  for l=1:2*p
	if (rand<prob)
	  if(l<=p)               %horizontal line - activate a row
		x(l*2-1:l*2,:)=1;
	  else                     %vertical line - activate a column
		x(:,(l-p)*2-1:(l-p)*2)=1;
	  end
    end
  end
  
 case 'quadwidth'
  %disp('4 pixel wide bar patterns (no overlap)');
  x=zeros(p*4,p*4);
  for l=1:2*p
	if (rand<prob)
	  if(l<=p)               %horizontal line - activate a row
		x(l*4-3:l*4,:)=1;
	  else                     %vertical line - activate a column
		x(:,(l-p)*4-3:(l-p)*4)=1;
	  end
	end
  end
  
 case 'doubleoverlap'
  %disp('double width bar patterns');
  for l=[1:p-1,p+1:2*p-1]
	if (rand<prob)
	  if(l<=p)               %horizontal line - activate a row
		x(l:l+1,:)=1;
	  elseif (l>p) %vertical line - activate a column
		x(:,l-p:l+1-p)=1;
	  end
    end
  end
  
 case 'unequal'
  if p~=16, disp('ERROR: image size of 16 expected for unequal bars problem');end
  prob_scale=4;
  %horizontal= 7x 1-pixel-wide plus 1x 9-pixel-wide
  for l=1:7  
	if (rand<prob/prob_scale)
	  x(l,:)=1;
	end
  end
  if (rand<prob/prob_scale) x(8:16,:)=1; end
  %vertical = 7x 1-pixel-wide plus 1x 9-pixel-wide
  for l=1:7 
	if (rand<prob)
	  x(:,l)=1;
	end
  end
  if (rand<prob) x(:,8:16)=1; end

 otherwise
  disp('ERROR: no bars problem defined');
end

x=x(:);

%add noise
if noise>0
  %add noise with given variance
%  x=x+(randn(size(x)).*sqrt(noise)); 
%  x(find(x>1))=1;
%  x(find(x<0))=0;
  
  %add bit-flip noise
  for i=1:length(x)
	if rand<noise
	  if x(i)>0.5, x(i)=0;
	  else x(i)=1; end
	end
  end
end


function x=fixedbars(x,p,num)
randSet=[];
for j=1:num
  newbar=0;
  while newbar==0 
	l=fix(1+(rand*2*p));
	newbar=1;
	for i=1:j-1 
	  if l==randSet(i) 
		newbar=0;
	  end
	end
  end
  randSet(j)=l;
  if(l<=p)                 %horizontal line - activate a row
	x(l,:)=1;
  else                     %vertical line - activate a column
	x(:,l-p)=1;
  end
end
