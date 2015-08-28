function results = test(k)

results = [];

tic;

for i=1:k,
    [X,W,V,U, n, r, c] = learn_bars_feedback();
    results = [results; [n, r, c]];
end;

toc;