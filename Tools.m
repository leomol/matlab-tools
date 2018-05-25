% Miscellaneous static functions.
% Tools methods:
%   argsToCell        - Standardize input arguments.
%   compare           - Compare strings.
%   compose           - Build a cell array of formatted strings from each input.
%   distance          - Pair wise distance between two position arrays.
%   exceptionToString - Convert an exception stack to text with hyperlinks.
%   stackHyperlink    - Create hyperlinks from a given stack.
%   tone              - Play a tone with the given frequency and duration.

% 2016-05-12. Leonardo Molina.
% 2018-05-24. Last modified.
classdef Tools
    methods (Static)
        function c = argsToCell(varargin)
            % c = Tools.argsToCell(inputs)
            % Convert different input formats to a standard cell array.
            % For example:
            %   argsToCell()                   --> {[]}
            %   argsToCell([])                 --> {[]}
            %   argsToCell({})                 --> {[]}
            %   argsToCell(arg1)               --> {arg1} (arg1 not an array).
            %   argsToCell(arg1, arg2, ...)    --> {arg1, arg2}
            %   argsToCell({arg1, arg2, ...})  --> {arg1, arg2}
            %   argsToCell([arg1, arg2, ...])  --> {arg1, arg2}
            
            n = numel(varargin);
            if n == 0
                % argsToCell()
                c = {[]};
            elseif n == 1
                test = varargin{1};
                if isempty(test)
                    % argsToCell([])
                    % argsToCell({})
                    c = {[]};
                elseif ismatrix(test) && ~ischar(test) && ~isstring(test)
                    if iscell(test)
                        % argsToCell({arg1, arg2, ...})
                        c = test;
                    else
                        % argsToCell([arg1, arg2, ...])
                        c = arrayfun(@(x) x, test, 'UniformOutput', false);
                        c = reshape(c, size(test));
                    end
                else
                    % argsToCell(arg1)
                    c = test;
                end
            else
                % argsToCell(arg1, arg2, ...)
                c = varargin;
            end
        end
        
        function v = compare(varargin)
            % Tools.compare(string1, string2, ...)
            % Test whether all consecutive pair of strings (mixed single or
            % double quotes) are equal.
            
            v = all(cellfun(@numel, varargin(1:2:end)) == cellfun(@numel, varargin(2:2:end))) && ...
                all(cat(2, varargin{1:2:end}) == cat(2, varargin{2:2:end}));
        end
        
        function composed = compose(format, varargin)
            % composed = Tools.compose(value)
            % composed = Tools.compose(format, value1, value2, ...)
            % composed = Tools.compose(format, {value1, value2, ...})
            % composed = Tools.compose(format, [number1, number2, ...])
            % Build a cell array of formatted strings from each input.
            % Values and numbers must be valid for the sprintf function.
            % The number of input rows must correspond to the number of
            % wildcards in format.
            % 
            % Examples:
            %   Tools.compose('[%s]', 'one', 'two', 'three')
            %   %==> {'[one]'} {'[two]'} {'[three]'}
            %   
            %   Tools.compose('%02i', [1 2 3])
            %   %==> {'01'} {'02'} {'03'}
            % 
            %   Tools.compose('%s:%.2f', {'x', 'y'; 1.11, 2.22})
            %   %==> {'x:1.11'} {'y:2.22'}
            
            values = Tools.argsToCell(varargin{:});
            nStrings = size(values, 2);
            composed = cell(1, nStrings);
            for j = 1:nStrings
                composed{j} = sprintf(format, values{:, j});
            end
        end
        
        function d = distance(x1, y1, x2, y2)
            % distance = distance(x1, y1, x2, y2)
            % Pair wise distance between all (x1, y1) and all (x2, y2) points.
            
            nc = numel(x2);
            np = numel(x1);
            d = NaN(np, nc);
            for c = 1:nc
                d(:, c) = (x1(:) - x2(c)) .^ 2 + (y1(:) - y2(c)) .^ 2;
            end
        end

        function str = exceptionToString(exception)
            % str = Tools.exceptionToString(exception)
            % Convert an exception stack to text with hyperlinks pointing
            % to the source code.
            
            str = sprintf( 'Error: %s\n', exception.message);
            for s = transpose(exception.stack)
                str = sprintf('%s%s', str, Tools.stackHyperlink(s));
            end
        end

        function str = stackHyperlink(stack)
            % str = Tools.stackHyperlink(stack)
            % Create hyperlinks from the information provided by the input
            % stack structure.
            
            [ ~, filename] = fileparts(stack.file);
            str = sprintf([ ...
            'In <a href="matlab:matlab.desktop.editor.openAndGoToLine', ...
            '(''%s'',%i);">%s.%s (line: %i)</a>\n'], ...
            stack.file, stack.line, filename, stack.name, stack.line);
        end
        
        function tone(frequency, duration)
            % Tools.tone(frequency, duration)
            % Play a tone with the given frequency (Hz) and duration (seconds) in the computer speaker.
            
            fs = min(44100, 18 * frequency * duration);
            t = 0:1/fs:duration;
            y = sin(2 * pi * frequency * t);
            sound(y, fs);
        end
    end
end