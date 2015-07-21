function Irecon=measure_reconstruction_quality(W,V,I)
%Reconstruct a mosaic of patches from a single image, and combine these to reconstruct the entire image
%W and V = the learnt FF and FB weights
%I = the image to be reconstructed

%DEFINE NETWORK PARAMETERS
iterations=200;     %number of iterations to calculate y (for each input)
[n,m]=size(W);
p=sqrt(m/2); 		%the rf width (assuming on/off channels and square rf)
[a,b]=size(I);
spacing=1;%p	    %define the degree of overlap between reconstructed patches

%GENERATE TEST DATA
sigmaLGN=1.5;
%convolve image with LOG filter and separate into ON and OFF channels
X=preprocess_V1_input(I,sigmaLGN);

%RECONSTRUCT IMAGE
Irecon=zeros(a,b); %matrix to sum up reconstructions of individual patches
Inorm=zeros(a,b);  %matrix to count the number of times each pixel has been reconstructed 					   %so result can be normalised
for i=1:spacing:a-p
  i
  for j=1:spacing:b-p
	%choose a patch of the image
	Pon=X{1}([i:i+p-1],[j:j+p-1]);
	Poff=X{2}([i:i+p-1],[j:j+p-1]);
	Patch=[Pon,Poff];
	x=Patch(:);

	%calculate node activations
	y=dim_activation(W,x,[],iterations,V);

	%calculate reconstruction of patch
	r=V'*y;
	r=reconstruct_V1RF(r',[p,p],sigmaLGN);
	ronoff=reshape(r(1:m/2)-r(m/2+1:m),p,p);
	Irecon(i:i+p-1,j:j+p-1)=Irecon(i:i+p-1,j:j+p-1)+ronoff;
	Inorm(i:i+p-1,j:j+p-1)=Inorm(i:i+p-1,j:j+p-1)+1;
  end
end
Irecon=Irecon./Inorm;

%plot results
figure(1),clf,
lim=max(max(abs(X{1}-X{2})))
imagesc(X{1}-X{2},[-lim,lim]);  
axis('equal','tight'); set(gca,'XTick',[],'YTick',[]); 
figure(2),clf,
lim=max(max(abs(Irecon)))
imagesc(Irecon,[-lim,lim]);  
axis('equal','tight'); set(gca,'XTick',[],'YTick',[]); 

