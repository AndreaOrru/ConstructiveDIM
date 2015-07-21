function RFrecon=reconstruct_V1RF(W,shape,sigma)
[n,m]=size(W);
LoG=filter_definitions_LGN(sigma);

for j=1:n, 
  %split weights into on and off channels
  Won=reshape(W(j,1:m/2),shape);
  Woff=reshape(W(j,m/2+1:m),shape);

  %convolve the ON and OFF weights with the LoG filter
  RFon=conv2(Won,LoG,'same');
  RFoff=conv2(Woff,-LoG,'same');

  %save reconstructd values
  RFrecon(j,:)=[RFon(:)',-RFoff(:)'];
end
