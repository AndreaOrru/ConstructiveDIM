function results = test(k)

results = [];

tic;

for i=1:k,
    [X,W,V,U, r] = learn_bars_feedback();
    results = [results; r];
end;

toc;