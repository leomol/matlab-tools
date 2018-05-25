% Byte - Generic operations on byte arrays.
% 
% Byte methods:
%   concatenate - Produce a number by concatenating bytes.
%   extract     - Extract a byte from the given number.
%   mask        - Produce a bitmask of the given width.
%   shift       - Bitshift an array of bytes.

% 2016-12-01. Leonardo Molina.
% 2018-05-21. Last modified.
classdef Byte
    methods (Static)
        function number = concatenate(varargin)
            % number = Byte.concatenate(bytes)
            % Produce a number by concatenanting bytes.
            
            bytes = cat(2, varargin{:});
            n = numel(bytes);
            number = 0;
            for b = 1:n
                number = bitor(number, bitshift(cast(bytes(b), 'uint64'), 8 * (n - b)));
            end
        end

        function byte = extract(number, position)
            % byte = Byte.extract(number, position)
            % Extract a byte from the given number.
            
            byte = bitand(bitshift(number, -8 * position), 255);
        end

        function m = mask(width)
            % m = Byte.mask(width)
            % Produce a bitmask of the given width.
            
            m = zeros(1, 1, 'uint64');
            for w = 1:width
                m = bitor(bitshift(m, 1), 1);
            end
        end
        
        function [bytes, remainder] = shift(bytes, s)
            % [bytes, remainder] = Byte.shift(byte, s)
            % Bitshift an array of bytes.
            
            bytes = cast(bytes, 'uint8');
            remainder = 0;
            if s > 0
                for b = 1:numel(bytes)
                    byte = bytes(b);
                    bytes(b) = bitor(bitshift(bytes(b), -s), remainder);
                    remainder = bitshift(byte, 8 - s);
                end
            elseif s < 0
                s = -s;
                for b = numel(bytes):-1:1
                    byte = bytes(b);
                    bytes(b) = bitor(bitshift(bytes(b), +s), remainder);
                    remainder = bitshift(byte, s - 8);
                end
            end
        end
    end
end