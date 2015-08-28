function results = test(k)

results = [];

tic;

for i=1:k,
    r = dim_squares();
    results = [results; r];
end;

toc;