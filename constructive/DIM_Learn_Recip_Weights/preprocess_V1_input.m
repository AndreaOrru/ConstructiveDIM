function [X]=preprocess_V1_input(I,sigma)
response_gain=2*pi;
[a,b,z]=size(I);
I=single(I);

LoG=filter_definitions_LGN(sigma);


for t=1:z %at each time step
  %calculate LGN neuron responses to input image
  Xonoff=conv2(I(:,:,t),LoG,'same');

%  Xonoff=Xonoff./max(max(abs(Xonoff)));
  %apply gain to response
  Xonoff=(response_gain.*Xonoff);

  %apply saturation to response
  Xonoff=tanh(Xonoff);

  %split into ON and OFF channels
  Xon=Xonoff;
  Xon(find(Xon<0))=0;
  Xoff=-Xonoff;
  Xoff(find(Xoff<0))=0;
  
  X{1}(:,:,t)=Xon;
  X{2}(:,:,t)=Xoff;  
end
