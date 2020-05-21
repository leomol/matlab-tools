% delta = circdiff(data, mn, mx);
% Calculate diff of points wrapped around mn and mx.
% 
% Example:
%   mn = 0;
%   mx = 10;
%   nCycles = 3;
%   data = mod(mn:3 * mx, mx);
%   fprintf('Data:\n  ');
%   disp(data);
%   delta = circdiff(data, mn, mx);
%   fprintf('Difference:\n  ');
%   disp(delta);

% 2020-05-16. Leonardo Molina.
% 2020-05-21. Last modified.
function delta = circdiff(data, mn, mx)
    if nargin < 2
        mn = min(data);
    end
    if nargin < 3
        mx = max(data);
    end
    delta = mod(diff(data - mn), mx - mn);
end