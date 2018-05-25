% Global - Organized access to variables in the global scope.
% 
% Global methods:
%   contains - Test whether global keys exist.
%   get      - Return the value associated to a global key.
%   remove   - Remove key-value pairs from the global container.
%   set      - Set a value associated to a global key.

% 2017-12-26. Leonardo Molina.
% 2018-05-21. Last modified.
classdef Global
    methods (Static)
        function result = get(key, default)
            % value = Global.get(key, default);
            %   Return the value associated to a global key, if it does not
            %   exist, return the default.
            % value = Global.get(key);
            %   Return the value associated to a global key, if it does not
            %   exist, throw an error.
            % keyValuePairs = Global.get();
            %   Return all key-value pairs.
            
            % Variable GlobalContainer must exist and belong to this class.
            global GlobalContainer;
            Global.test();
            
            if nargin == 0
                % Without arguments, return all key-value pairs.
                result = GlobalContainer;
            else
                k = ismember(GlobalContainer(1, :), key);
                if any(k)
                    % When key exists, return the value contained.
                    result = GlobalContainer{2, k};
                elseif nargin == 2
                    % When key does not exist, set and return the default.
                    result = default;
                    GlobalContainer(:, end + 1) = {key, default};
                else
                    error('Key "%s" does not exist and a default value was not provided.', key);
                end
            end
        end
        
        function set(varargin)
            % Global.set(key1, value1, key2, value2, ...)
            % Set a value associated to a global key.
            
            global GlobalContainer;
            Global.test();
            
            pairs = Tools.argsToCell(varargin{:});
            keys = pairs(1:2:end);
            values = pairs(2:2:end);
            % Replace existing.
            [~, g, k] = intersect(GlobalContainer(1, :), keys);
            GlobalContainer(2, g) = values(k);
            % Append unexisting.
            [~, k] = setdiff(keys, GlobalContainer(1, :));
            GlobalContainer(:, end + 1: end + sum(k)) = [keys(k); values(k)];
        end
        
        function varargout = contains(varargin)
            % Global.contains(key1, key2, ...)
            % Test whether one or more keys exist in the global container
            % and return the result as a boolean array.
            
            global GlobalContainer;
            Global.test();
            keys = Tools.argsToCell(varargin{:});
            varargout(1:nargout) = num2cell(ismember(keys, GlobalContainer(1, :)));
        end
        
        function remove(varargin)
            % Global.remove(key1, key2, ...)
            % Remove keys from the global container.
            
            global GlobalContainer;
            Global.test();
            keys = Tools.argsToCell(varargin{:});
            k = ismember(GlobalContainer, keys);
            GlobalContainer(:, k) = [];
        end
    end
    
    methods (Access = private, Static)
        function test()
            global GlobalContainer;
            if ~iscell(GlobalContainer)
                GlobalContainer = cell(2, 0);
            end
        end
    end
end