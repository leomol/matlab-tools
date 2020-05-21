% Callbacks - Generic methods to invoke methods or functions with arbitrary
% number of arguments. Further arguments may be appended to input callbacks.
% When invoking methods, the validity of the object may also be checked.
% 
% 
% Callbacks methods:
%   invoke - Invoke a method or a function with arguments.
%   void   - Generic function with arbitrary number of inputs and outputs.

% 2016-05-12. Leonardo Molina.
% 2018-06-08. Last modified.
classdef Callbacks
    methods (Static)
        function invoke(varargin)
            % Callbacks.invoke(functionHandle, arg1, arg2, ...)
            % Callbacks.invoke({functionHandle, arg1, arg2, ...}, arg3, ...)
            % Callbacks.invoke(objectHandle, methodName, arg1, arg2, ...)
            % Callbacks.invoke({objectHandle, methodName, arg1, arg2, ...}, arg3, ...)
            % Executes a function or an object method with the provided
            % arguments. This definition is suited for MATLAB's TimerFcn
            % because it tests for object validity prior to the execution of a
            % method which may be necessary when MATLAB unadvertly postpones 
            % stopping or deleting of timers (whilst execution is documented 
            % as being synchronous).
            % 
            % Examples:
            %   Callbacks.invoke(@fprintf, '%s %s\n', 'Hello', 'world')
            %   Callbacks.invoke({@fprintf, '%s %s %s\n', 'Hello', 'world'}, '!')
            %  
            %   t = timer('TimerFcn', @(~, ~)disp('Tic'));
            %   Callbacks.invoke(@t.start);
            %   Callbacks.invoke(t, 'start');
            %   delete(t);
            %   Callbacks.invoke(t, 'start');
            if iscell(varargin{1})
                % invoke({...}, ...)
                args = [varargin{1} varargin(2:end)];
            else
                args = varargin;
            end
            if isobject(args{1})
                % invoke(obj, ...)
                obj = args{1};
                if Objects.isValid(obj)
                    methodName = args{2};
                    obj.(methodName)(args{3:end});
                end
            else
                % invoke(functionHandle, ...)
                functionHandle = args{1};
                functionHandle(args{2:end});
            end
        end
        
        function varargout = void(varargin)
            % varargout = Callbacks.void(varargin)
            % Takes an arbitrary number of inputs and returns an arbitrary
            % number of boolean outputs set to false. This function may be
            % used as the default value of a callback which provides an
            % alternative to validating against the empty type.
            % Examples:
            %   MyClass.m:
            %     classdef MyClass < handle
            %         properties
            %             callback = Callbacks.void;
            %         end
            %         methods
            %             function call(obj)
            %                 obj.callback();
            %             end
            %         end
            %     end
            %   test.m:
            %     myObject = MyClass();
            %     myObject.call();
            %     myObject.callback = @() disp('Hello world');
            %     myObject.call();
            %   test();
            varargout(1:nargout) = num2cell(false(1, nargout));
        end
    end
end