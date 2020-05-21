function n = nDecimals(number, maxDecimals, threshold)
    if nargin < 2
        maxDecimals = 10;
    end
    if nargin < 3
        threshold = eps;
    end

    n = 0;
    k = 1;
    while abs(number - round(number * k) / k) > threshold && n < maxDecimals
        n = n + 1;
        k = k * 10;
    end
end