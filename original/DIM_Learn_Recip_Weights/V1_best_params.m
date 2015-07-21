function best_params=V1_best_params(W,V,node)
%function best_params=V1_best_params(W,V,node) 
%
%Given the weights (W and V) for a model of V1, this function finds the
%parameters of a sinusoidal grating that produces the strongest response from
%the neuron with index "node".

sigmaLGN=1.5;
[n,m]=size(W);
max_diam=sqrt(m/2); %calc rf diam (assuming on/off channels and square rf)

%define range of parameters to test
grating_angles=[-90:7.5:90];
grating_diams=[3:2:max_diam];
grating_wavels=[4:0.25:8];
grating_phases=[-90:15:90];

contrast=0.8;
iterations=12;

%systematicallly test each combination of parameters to find those that
%generate the highest response from the node
max_resp=0;
for gd=grating_diams
  border=(max_diam-gd)/2;
  for gw=grating_wavels
	for ga=grating_angles
	  for gp=grating_phases
		I=image_circular_grating(gd,border,gw,ga,gp,contrast); 
		[a,b]=size(I);
		x=preprocess_V1_input(I,sigmaLGN);
		X=[x{1},x{2}];X=X(:);

		%perform competition
		%y=dim_activation(W,X,[],iterations,V);
		%resp=y(node);

		%perform competition
		Y=dim_activation_sequence(W,X,iterations,V);
		resp=mean(Y(node,:));
		
		if resp>max_resp
		  %update the best parameters found so far
		  best_params=[gd,gw,ga,gp];
		  max_resp=resp;
		end
	  end
	end 
  end
end
max_resp
best_params

