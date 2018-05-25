% Compression - Compression and decompression of numbers.
% Operations are meant to reduce bandwidth during serial communication.
% Numbers are positive integers smaller than 2^64.
% 
% Compression Methods:
%   compress   - Pack an array of integers into a byte array.
%   decompress - Unpack numbers from a byte array.
%   extract    - Extract a number from a subset of bits from another number.

% 2016-12-01. Leonardo Molina.
% 2018-05-25. Last modified.
classdef Compression
    methods (Static)
        function bytes = compress(numbers, sizes)
            % bytes = Compression.compress(numbers, sizes)
            % Pack an array of numbers into a byte array. Each number is
            % represented by a sequence of bits of the given size.
            % 
            % Example:
            %   array1 = Compression.compress([255, 0, 255], [8, 8, 8])
            %   %==> 255 0 255 ==> 11111111 00000000 11111111
            %   Compression.compress([7, 0, 4095], [5, 8, 12])
            %   %==> 56 7 255 128 ==> 00111000 00000111 11111111 10000000
            
            % Index of current target byte.
            id = 1;
            % Cummulative number of bits.
            cum = 0;
            % Output array.
            bytes = zeros(1, ceil(sum(sizes) / 8), 'uint8');
            for k = 1:numel(numbers)
                cum = cum + sizes(k);
                % Index of byte carrying least significant digit.
                l = ceil(cum / 8);
                % Number of left-shifts for left-alignment.
                s = 8 * l - cum;
                number = bitshift(numbers(k), s);
                % Extract one byte at a time.
                for b = id:l
                    bytes(b) = bitor(bytes(b), Byte.extract(number, l - b));
                end
                id = l;
                % Move to the next byte when full.
                if mod(cum, 8) == 0
                    id = id + 1;
                end
            end
        end
        
        function [numbers, remainder] = decompress(bytes, sizes)
            % [numbers, remainder] = Compression.decompress(bytes, sizes);
            % Unpack numbers from a byte array. Each number is represented
            % by a sequence of bits of the given size.
            % 
            % Example:
            %   data = Compression.compress([15, 0, 15, 0], [4 4 4 4]);
            %   Compression.decompress(data, [4 4 4 4])
            %   %==> 15, 0, 15, 0
            
            % Initialize output.
            numbers = NaN(size(sizes));
            % First datum starts at position zero.
            remainder = zeros(1, 'uint64');
            bytes = cast(bytes, 'uint64');
            nremainder = 0;
            from = 1;
            for s = 1:numel(sizes)
                width = sizes(s);
                % Append required number of bytes.
                nbytes = ceil((width - nremainder) / 8);
                to = from + nbytes - 1;
                buffer = [remainder, bytes(from:to)];
                % Align to the left and decompress.
                buffer = Byte.shift(buffer, nremainder - 8);
                aligned = Byte.concatenate(buffer);
                numbers(s) = Compression.extract(aligned, 8 * (nbytes + 1), width);
                % Get leftover data.
                nremainder = mod(8 - mod(width - nremainder, 8), 8);
                remainder = bitand(bytes(to), Byte.mask(nremainder));
                from = from + nbytes;
            end
        end
        
        function number = extract(number, start, width)
            % number = Compression.extract(number, start, width)
            % Extract a number from a subset of bits from another number.
            % The bit range is given by the start (counting from the right)
            % and the width.
            % 
            % Example:
            %   data = bin2dec(['00111' '00000000' '1111111111110000000']);
            %   Compression.extract(data, 32, 5)  %==> 7
            %   Compression.extract(data, 27, 8)  %==> 0
            %   Compression.extract(data, 19, 12) %==> 4095
            
            tmp = bitshift(number, width - start);
            number = bitand(tmp, Byte.mask(width));
        end
    end
end