filename='natural_weights_20kcycs_cont_learning_p11_n180.mat'
weights=W;%Wcorrel;
shape=[11,11];
best_fitNew=fit_gabor_with_ga(weights,shape,1.5,best_fit_params);
best_fit_paramsNew=best_fit_params;
load(filename);
best_fit=fit_gabor_with_ga(weights,shape,1.5,best_fit_params);

ind=find(best_fitNew<best_fit)

for r=ind
	best_fit_params(r,:)=best_fit_paramsNew(r,:);
end
if length(ind)>0
  best_fit=fit_gabor_with_ga(weights,shape,1.5,best_fit_params);
  save(filename,'W','V','U','best_fit','best_fit_params')
  %save(filename,'W','V','U','best_fit','best_fit_params','Wcorrel')
end
