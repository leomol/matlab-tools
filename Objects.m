% Objects - Safely delete objects or check for their validity.
% 
% Objects methods:
%   delete   - Delete one or more objects in a valid state.
%   isHandle - Test if one or more inputs are valid graphic handles.
%   isValid  - Test if one or more inputs are valid objects.

% 2016-05-12. Leonardo Molina.
% 2018-05-21. Last modified.
classdef Objects
    methods (Static)
        function assign(object, field, value)
            % Objects.assign(field, value)
            % Assign a value to an object's field.
            % Example:
            %   container = Container('a', 1);
            %   Callbacks.invoke(@Objects.assign, container, 'a', 2);
            %   disp(container.a);
            
            object.(field) = value;
        end
        
        function delete(varargin)
            % Objects.delete(object1, object2, ...)
            % Objects.delete([object1, object2, ...])
            % Objects.delete({object1, object2, ...})
            % Delete one or more objects in a valid state.
            
            targets = Tools.argsToCell(varargin{:});
            for t = 1:Objects.numel(targets)
                if Objects.isValid(targets{t})
                    delete(targets{t});
                end
            end
        end
        
        function result = isValid(varargin)
            % result = Objects.isValid(object1, object2, ...)
            % result = Objects.isValid([object1, object2, ...])
            % result = Objects.isValid({object1, object2, ...})
            % Test if one or more inputs are valid objects.
            
            targets = Tools.argsToCell(varargin{:});
            result = false(size(targets));
            for r = 1:numel(result)
                % MATLAB errors when testing if "isvalid" is a method of an invalid object.
                % Forced solution: try-catch.
                try
                    valid = isvalid(targets{r});
                catch
                    valid = true;
                end
                result(r) = isobject(targets{r}) && valid;
            end
        end
        
        function result = isHandle(varargin)
            % result = Objects.isHandle(object1, object2, ...)
            % result = Objects.isHandle([object1, object2, ...])
            % result = Objects.isHandle({object1, object2, ...})
            % Test if one or more objects are valid graphic handles.
            
            targets = Tools.argsToCell(varargin{:});
            result = false(size(targets));
            for r = 1:numel(result)
                result(r) = ~isempty(targets{r}) && ishandle(targets{r});
            end
        end
        
        function result = numel(list)
            % result = Objects.numel(list)
            % Return number of elements in an object of type list,
            % for which MATLAB's numel would return 1.
            result = prod(size(list)); %#ok<PSIZE>
        end
    end
end