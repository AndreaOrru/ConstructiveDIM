function results = test(k)

results = [];

tic;

for i=1:k,
    [n, r, c] = dim_squares();
    results = [results; [n, r, c]];
end;

toc;