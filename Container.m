% Container - Facilitate data exchange from event listeners.
% 
% Container methods:
%   set - Set or update dynamic properties in the container object.
% 
% Example:
%   container = Container('field1', 1, 'field2', 1:5);
%   container.set('greeting', 'Hello world');
%   disp(container.field1);
%   disp(container.field2);
%   disp(container.greeting);

% 2016-05-12. Leonardo Molina.
% 2018-05-25. Last modified.
classdef Container < dynamicprops & event.EventData
    methods
        function obj = Container(varargin)
            % Container(field1, value1, field2, value2, ...)
            % Returns a Container object.
            % Set dynamic properties in the container object.
            %
            % Example: 
            %   container = Container('field1', 1, ...)
            %   container.field1 %==> 1
            % 
            % See also Container.set.
            obj.set(varargin{:});
        end
        
        function set(obj, varargin)
            % Container.set(field1, value1, field2, value2, ...)
            % Set dynamic properties in the container object, if a property
            % already exists, modify its value.
            % 
            % Example 1:
            %   container = Container();
            %   container.set('field1', 1, 'field2', 1:5, 'anotherTag', {'Hello', 123});
            %   container.field1 %==> 1
            % 
            % Example 2:
            % Create TestClass.m:
            %   classdef TestClass < handle
            %       events
            %           Called;
            %       end
            % 
            %       methods (Access = private)
            %           function call(obj)
            %               obj.notify('Called', Container('Greeting', 'Hello world', 'Field2', 2, 'Field3', 1:5));
            %           end
            %        end
            %       
            %       methods (Static)
            %           function test()
            %               testObject = TestClass();
            %               addlistener(testObject, 'Called', @(source, event)disp(event.Greeting));
            %               testObject.call();
            %           end
            %       end
            %   end
            % 
            % Then execute:
            %   TestClass.Test();
            
            n = numel(varargin);
            for i = 1:2:n
                if ~isprop(obj, varargin{i})
                    obj.addprop(varargin{i});
                end
                obj.(varargin{i}) = varargin{i + 1};
            end
        end
    end
    
    % Hide methods inherited from dynamicprops.
    methods (Hidden)
        function lh = addlistener(varargin)
            lh = addlistener@dynamicprops(varargin{:});
        end
        function notify(varargin)
            notify@dynamicprops(varargin{:});
        end
        function delete(varargin)
            delete@dynamicprops(varargin{:});
        end
        function Hmatch = findobj(varargin)
            Hmatch = findobj@dynamicprops(varargin{:});
        end
        function p = findprop(varargin)
            p = findprop@dynamicprops(varargin{:});
        end
        function TF = eq(varargin)
            TF = eq@handle(varargin{:});
        end
        function TF = ne(varargin)
            TF = ne@handle(varargin{:});
        end
        function TF = lt(varargin)
            TF = lt@handle(varargin{:});
        end
        function TF = le(varargin)
            TF = le@handle(varargin{:});
        end
        function TF = gt(varargin)
            TF = gt@handle(varargin{:});
        end
        function TF = ge(varargin)
            TF = ge@handle(varargin{:});
        end
        function p = addprop(varargin)
            p = addprop@dynamicprops(varargin{:});
        end
    end
end