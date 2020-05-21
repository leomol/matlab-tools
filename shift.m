% s = shift(t1, t2)
% Find optimal offset such that t2 + s has highest "correlation" with t1.
% 
% Example:
%   t1 = [1,  10, 100, 1000, 1010];
%   t2 = [   100, 190,       1100];
%   s = shift(t1, t2);
%   disp(t2 + s);
%   disp([t1; ismember(t1, t2 + s)]);

% 2020-03-21. Leonardo Molina.
% 2020-05-21. Last modified.
function s = shift(t1, t2)
    t1 = unique(t1(:));
    t2 = unique(t2(:));
    lowest = Inf;
    for i = 1:numel(t1)
        for j = 1:numel(t2)
            s = t1(i) - t2(j);
            k = score(t1, t2 + s);
            if k < lowest
                lowest = k;
                best = [i, j];
            end
        end
    end
    s = t1(best(1)) - t2(best(2));
end

function k = score(t1, t2)
    d = abs(t2(:)' - t1(:));
    k = sum(min(d));
end