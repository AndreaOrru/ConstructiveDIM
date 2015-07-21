function [params,diff]=diff_gabor(params,opts)
global w;
global w_sum_of_squares;
[a,b]=size(w);
west=gabor_offcentre_interp_params(params,a);
diff=-sum(sum((w-west).^2))./w_sum_of_squares;
