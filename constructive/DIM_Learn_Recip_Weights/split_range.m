function ranges=split_range(numPixels,numSubRegions,overlap)
%ranges=split_range(numPixels,numSubRegions,overlap)
%
%Attempts to split a square input image (of size "numPixels") into a specified
%number ("numSubRegions") of equal sized square sub-regions. These sub-regions
%either do not overlap (unless some overlap is necesary to tile the whole input
%image) or do overlap so that neighbouring regions overlap by approximately half
%their width.
%The output is the ranges of indices that should be used to form each region.

lenRegion=sqrt(numPixels);
numSide=sqrt(numSubRegions);
if numSide~=floor(numSide) | lenRegion~=floor(lenRegion)
  error('numSubRegions and numPixels must be the square of an integer value');
end
if overlap
  %if (lenRegion==odd(lenRegion) & numSide==odd(numSide)) | ...
%	(lenRegion~=odd(lenRegion) & numSide~=odd(numSide))
%	makeodd=1;
%  else
%	makeodd=0;
%  end
  if lenRegion==odd(lenRegion) %makeodd
	lenSubRegion=odd(2*lenRegion/(numSide+1),0);%regions have sides that are odd
	lenSubRegion=max(3,lenSubRegion);
  else
	lenSubRegion=odd(2*lenRegion/(numSide+1))-1; %regions have sides that are even
  end
else
  lenSubRegion=ceil(lenRegion/numSide);
end
hlen=(lenSubRegion-1)/2;
if numSide==1
  spacing=1; 
else
  spacing=(lenRegion-hlen-(1+hlen))/(numSide-1);
end
for r=1:numSide
  cent=1+hlen+(r-1)*spacing;
  ranges(r,:)=round([cent-hlen:cent+hlen]);
end
ranges
