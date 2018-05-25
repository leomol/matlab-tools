% Scheduler - Invoke functions or methods with a delay.
% 
% Scheduler methods:
%   delay  - Invoke a method or function with a delay.
%   repeat - Invoke a method or function with repetition.
%   stop   - Stop all processes.
% 
% Example 1:
%     % Print Hello after 1 second.
%     obj = Scheduler();
%     obj.delay({@disp, 'Hello'}, 1);
% 
% Example 2:
%     % Print elapsed time every second.
%     obj = Scheduler();
%     tic
%     handle = obj.repeat(@()fprintf('Elapsed: %.0fs\n', toc), 1);
%     % Stop process after 5 seconds.
%     obj.delay({@delete, handle}, 5);

% 2016-05-12. Leonardo Molina.
% 2018-05-25. Last modified.
classdef Scheduler < handle
    properties (Access = private)
        tickers = []
        count = 0
        className
    end
    
    methods
        function obj = Scheduler()
            % Scheduler.Scheduler
            % Creates an scheduler which invokes user callbacks after a delay or with a
            % given periodicity.
            
            obj.className = mfilename('class');
        end
        
        function delete(obj)
            Timers.delete(obj.tickers);
        end
        
        function handle = delay(obj, callback, delay)
            % handle = Scheduler.delay(callback, delay)
            % Invoke a callback after the given delay. Output handle is a 
            % reference to this process.
            % See also Callbacks.repeat.
            
            handle = obj.repeat(callback, delay, 1);
        end
        
        function handle = repeat(obj, callback, period, repetitions)
            % handle = Scheduler.repeat(period, callback, repetitions)
            % Invoke a callback a number of times, with the given
            % periodicity. Repetitions defaults to infinity.
            % Output handle is a reference to this process.
            % See also Callbacksstop, Callbacks.invoke.
            
            period = min(max(round(period * 1e3), 0), 2.1474e6) / 1e3;
            if ~iscell(callback)
                callback = {callback};
            end
            if nargin < 4
                repetitions = Inf;
            end
            if period == 0
                ticker = timer();
                handle = Scheduler.Handle(ticker);
                Callbacks.invoke(callback{:});
            else
                if repetitions == 1
                    ticker = timer('Name', obj.className, 'TimerFcn', {@Timers.finalize, callback{:}}, 'ExecutionMode', 'fixedSpacing', 'StartDelay', period, 'Period', period, 'TasksToExecute', repetitions, 'BusyMode', 'queue'); %#ok<CCAT>
                else
                    ticker = timer('Name', obj.className, 'TimerFcn', {@Timers.forward, callback{:}}, 'ExecutionMode', 'fixedSpacing', 'StartDelay', period, 'Period', period, 'TasksToExecute', repetitions, 'BusyMode', 'drop'); %#ok<CCAT>
                end
                handle = Scheduler.Handle(ticker);
                start(ticker);
            end
            obj.tickers = [obj.tickers, ticker];
        end
        
        function stop(obj)
            % Scheduler.stop()
            % Stop all processes.
            % See also Scheduler.repeat, Callbacks.call.
            
            Timers.delete(obj.tickers);
            obj.tickers = [];
        end
    end
    
    methods (Static)
        function handle = Delay(varargin)
            handle = Scheduler.Instance().delay(varargin{:});
        end
        
        function instance = Instance()
            if Global.contains('Scheduler')
                instance = Global.get('Scheduler');
            else
                instance = Scheduler();
                Global.set('Scheduler', instance);
            end
        end
        
        function handle = Repeat(varargin)
            handle = Scheduler.Instance().repeat(varargin{:});
        end
        
        function Stop()
            Scheduler.Instance().stop();
        end
    end
end