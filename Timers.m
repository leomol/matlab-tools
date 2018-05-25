% Timers - Generic operations on timers.
% 
% Timers methods:
%   delete   - Delete one or more timer objects.
%   finalize - Invoke a timer function without the timer's data, then
%              delete the timer.
%   forward  - Invoke a timer function without the timer's data.
%   pause    - Pause a "thread" without blocking others.
%   stop     - Stop one or more timer objects.

% 2016-05-12. Leonardo Molina.
% 2018-03-22. Last modified.
classdef Timers
    methods (Static)
        function delete(varargin)
            % Timers.delete(timer1, timer2, ...)
            % Timers.delete([timer1, timer2, ...])
            % Timers.delete({timer1, timer2, ...})
            % Delete one or more timers. The method waits for single-shot
            % timers to be on a deletable state.
            % Errors won't be thrown for timers with an invalid state.
            
            targets = Tools.argsToCell(varargin{:});
            for t = 1:Objects.numel(targets)
                target = targets{t};
                if isa(target, 'timer') && isvalid(target)
                    try
                        stop(target);
                        if strcmp(target.ExecutionMode, 'singleShot')
                            wait(target);
                        end
                        delete(target);
                    catch
                    end
                end
            end
        end
        
        function finalize(handle, ~, varargin)
            % Timers.finalize(handle, ~, callback).
            % Same behavior as Timers.forward, except that the timer object
            % will be stopped and deleted when the timer function is
            % invoked.
            
            Timers.delete(handle);
            try
                Callbacks.invoke(varargin{:});
            catch exception
                error(Tools.exceptionToString(exception));
            end
        end
        
        function forward(~, ~, varargin)
            % Timers.forward(~, ~, callback).
            % Wrap around a timer function so that the arguments pushed by
            % the timer function (timer handle and event) are not forwarded
            % to the callback function. Unlike MATLAB's default behavior,
            % where errors in the timer function are handled as warnings, 
            % execution will halt instead as expected and an exception 
            % trace will be displayed.
            % The callback function has the signature described in
            % Callbacks.invoke.
            % 
            % See also Callbacks.invoke.
            
            try
                % Catch error here so that MATLAB's timer does not hide the
                % error as a warning.
                Callbacks.invoke(varargin{:});
            catch exception
                % When an error occurs, MATLAB may forcibly show it as a 
                % warning but here its stack trace will be displayed.
                error(Tools.exceptionToString(exception));
            end
        end
        
        function pause(duration)
            % Timers.pause(duration)
            % Pause "thread" for the given duration. This method behaves
            % similarly to the native command pause in newer versions of
            % MATLAB, in that it does not block other timers.
            
            start = tic;
            while toc(start) < duration
                drawnow('nocallbacks');
            end
        end
        
        function stop(varargin)
            % Timers.stop(timer1, timer2, ...)
            % Timers.stop([timer1, timer2, ...])
            % Timers.stop({timer1, timer2, ...})
            % Stop one or more timer objects.
            % Errors won't be thrown for timers with an invalid state.
            
            targets = Tools.argsToCell(varargin{:});
            for t = 1:Objects.numel(targets)
                target = targets{t};
                if isa(target, 'timer') && isvalid(target)
                    stop(target);
                    if strcmp(target.ExecutionMode, 'singleShot')
                        wait(target);
                    end
                end
            end
        end
    end
end