function results = test(k)

results = [];

tic;

for i=1:k,
    [r, n] = dim_squares();
    results = [results; [r, n]];
end;

toc;