function [best_fit,best_fit_params]=META_fit_gabor_with_ga(W,shape,sigmaLGN,best_fit_params,trials)

if nargin>=4
  best_fit=fit_gabor_with_ga(W,shape,sigmaLGN,best_fit_params);
else
  best_fit=Inf;
end
if nargin<5
  trials=4;
end

for t=1:trials;
  [best_fitNew,best_fit_paramsNew]=fit_gabor_with_ga(W,shape,sigmaLGN);

  ind=find(best_fitNew<best_fit)
  if length(best_fit)==1, best_fit=best_fitNew; end
  
  for r=ind
	best_fit_params(r,:)=best_fit_paramsNew(r,:);
	best_fit(r)=best_fitNew(r);
  end
end
