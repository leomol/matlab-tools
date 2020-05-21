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
% 2018-08-22. Last modified.
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
                        if prod(size(test)) > 1 %#ok<PSIZE>
                            c = arrayfun(@(x) x, test, 'UniformOutput', false);
                            c = reshape(c, size(test));
                        else
                            c = {test};
                        end
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
        
        function [m, i, j] = mask(ux, uy, xResolution, yResolution)
            % [mask, i, j] = Tools.mask(ux, uy, xResolution, yResolution)
            % Generate a binary mask from region in normalized units for the
            % current resolution.
            
            % Convert normalized units to pixels.
            if isempty(ux)
                m = false(yResolution, xResolution);
                i = [];
                j = [];
            else
                d = min(xResolution, yResolution);
                px = 0.5 * xResolution + ux * d;
                py = 0.5 * yResolution + uy * d;
                [ii, jj] = find(true(yResolution, xResolution));
                [a, b] = inpolygon(jj, ii, px, py);
                a = a | b;
                m = false(yResolution, xResolution);
                m(a) = true;
                i = ii(a);
                j = jj(a);
            end
        end
        
        function [ux, uy] = normalize(px, py, xResolution, yResolution)
            % [ux, uy] = Tools.normalize(px, py, xResolution, yResolution)
            % Re-scale region in pixels to normalized units.
            
            % Normalize to smallest dimension and make relative to center.
            d = min(xResolution, yResolution);
            ux = (px - 0.5 * xResolution) / d;
            uy = (py - 0.5 * yResolution) / d;
        end
        
        function [px, py] = pixelate(ux, uy, xResolution, yResolution)
            % [px, py] = Tools.pixelate(ux, uy, xResolution, yResolution)
            % Re-scale region in normalized units to pixels.
            
            % Normalize to smallest dimension and make relative to center.
            d = min(xResolution, yResolution);
            px = 0.5 * xResolution + ux * d;
            py = 0.5 * yResolution + uy * d;
        end

        function output = reinterpret(input)
            % signed = reinterpret(unsigned)
            % unsigned = reinterpret(signed)
            %
            % Reinterprets a 8- 16- 32- or 64-bit signed/unsigned number to an unsigned/signed number.
            % Overflowed numbers are zero'd.
            %
            % Examples:
            %   reinterpret(int8(-1))   % -->  -1 [10000001] --> 129
            %   reinterpret(uint8(129)) % --> 129 [10000001] --> -1
            
            sourceType = class(input);
            switch sourceType
                case 'uint8'
                    mask = uint8(2^7);
                    destinationType = 'int8';
                case 'uint16'
                    mask = uint16(2^15);
                    destinationType = 'int16';
                case 'uint32'
                    mask = uint32(2^31);
                    destinationType = 'int32';
                case 'uint64'
                    mask = uint64(2^63);
                    destinationType = 'int64';
                case 'int8'
                    mask = uint8(2^7);
                    destinationType = 'uint8';
                case 'int16'
                    mask = uint16(2^15);
                    destinationType = 'uint16';
                case 'int32'
                    mask = uint32(2^31);
                    destinationType = 'uint32';
                case 'int64'
                    mask = uint64(2^63);
                    destinationType = 'uint64';
                otherwise
                    error('Uncompatible type.');
            end
            if sourceType(1) == 'u'
                if bitand(input, mask) == mask
                    s = -1;
                else
                    s = +1;
                end
                output = s * cast(bitand(input, mask - 1), destinationType);
            else
                if input >= 0
                    output = cast(abs(input), destinationType);
                else
                    output = bitor(cast(abs(input), destinationType), mask);
                end
            end
        end
        
        function [xs, ys] = region(region, circleResolution)
            % [xs, ys] = region(region)
            % region is a polygon [x1, y1, x2, y2, x3, y3...]
            % 2-point regions (i.e. [x1, y1, x2, y2]) are reinterpreted as:
            %   -Rectangles if the two points draw a rectangle or,
            %   -Circles when the two points draw a line.
            % 3-number regions (i.e. [x, y, r]) are reinterpreted as circles
            % centered at (x, y) and radius r.

            if isempty(region)
                xs = [];
                ys = [];
            elseif numel(region) == 3
                % Circle. Center and radius.
                cx = region(1);
                cy = region(2);
                r = region(3);
                angles = linspace(0, 2 * pi, circleResolution);
                xs = r * sin(angles) + cx;
                ys = r * cos(angles) + cy;
            elseif numel(region) < 3 || mod(numel(region), 2) ~= 0
                error('Value provided for region is invalid.');
            elseif numel(region) == 4
                region = transpose(region(:));
                % Two-point regions are considered corners of a rectangle or boundaries of a circle.
                ux = region([1, 3]);
                uy = region([2, 4]);
                if ux(1) == ux(2)
                    % Circle. Vertical reference.
                    cx = ux(1);
                    cy = 0.5 * sum(uy);
                    r = 0.5 * abs(diff(uy));
                    angles = linspace(0, 2 * pi, circleResolution);
                    xs = r * sin(angles) + cx;
                    ys = r * cos(angles) + cy;
                elseif uy(1) == uy(2)
                    % Circle. Horizontal reference.
                    cx = 0.5 * sum(ux);
                    cy = uy(1);
                    r = 0.5 * abs(diff(ux));
                    angles = linspace(0, 2 * pi, circleResolution);
                    xs = r * sin(angles) + cx;
                    ys = r * cos(angles) + cy;
                else
                    % Rectangle.
                    x1 = min(ux);
                    y1 = min(uy);
                    x2 = max(ux);
                    y2 = max(uy);
                    xs = [x1, x2, x2, x1];
                    ys = [y1, y1, y2, y2];
                end
            else
                xs = region(1:2:end);
                ys = region(2:2:end);
            end
        end

        function [x2, y] = rotate(x, y, degrees)
            % [x, y] = rotate(x, y, degrees)
            % Rotate x and y a number of degrees (right-hand coordinate system).

            radians = degrees / 180 * pi;
            cosv = cos(radians);
            sinv = sin(radians);
            x2(:) = x * cosv - y * sinv;
            y(:) =  y * cosv + x * sinv;
        end
        
        function tone(frequency, duration)
            % Tools.tone(frequency, duration)
            % Play a tone with the given frequency (Hz) and duration (seconds) in the computer speaker.
            
            fs = min(44100, max(1000, 9 * frequency));
            t = 0:1 / fs:duration;
            y = sin(2 * pi * frequency * t);
            sound(y, fs);
        end
    end
end