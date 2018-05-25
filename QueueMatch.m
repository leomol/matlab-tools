% QueueMatch - Push values to a string builder and test a match to a given
% target.
% 
% QueueMatch methods:
%   push - Aggregate data to the string builder and test for a match.

% 2016-05-12. Leonardo Molina.
% 2018-05-21. Last modified.
classdef QueueMatch < handle
    properties (Access = private)
        target
        nCompleted = 0
    end
    
    methods
        function obj = QueueMatch(target)
            % QueueMatch(target)
            % Create a string builder.
            
            obj.target = target;
        end
        
        function [nc, at] = push(obj, input)
            % [count, position] = push(input)
            % Test for a target match in the string constructed so far.
            % Return count and position of the match.
            
            nc = obj.nCompleted;
            at = 0;
            if ~isempty(obj.target)
                for c = 1:Objects.numel(input)
                    if input(c) == obj.target(nc + 1)
                        at = c;
                        obj.nCompleted = obj.nCompleted + 1;
                        nc = obj.nCompleted;
                        if nc == Objects.numel(obj.target)
                            obj.nCompleted = 0;
                            break;
                        end
                    else
                        at = 0;
                        nc = 0;
                        obj.nCompleted = 0;
                    end
                end
            end
        end
    end
end