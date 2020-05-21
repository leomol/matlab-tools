% Ticker - Invoke functions or methods at an interval or with a delay.
% You should make calls to the static form so that only one timer runs all
% your tickers, otherwise one timer per ticker will be created and MATLAB
% will hang as it cannot support many timer objects firing simultaneously.
% 
% Ticker methods:
%   delay  - Invoke a method or function with a delay.
%   repeat - Invoke a method or function with repetition.
%   stop   - Stop all processes.
% 
% Example 1:
%     % Print Hello after 1 second.
%     Ticker.Delay(@()disp('Hello'), 1);
% 
% Example 2:
%     % Multiple timers:
%     Ticker.Delay(@()disp('One'), 1);
%     Ticker.Delay(@()disp('--> Uno'), 1);
%     Ticker.Delay(@()disp('Two'), 2);
%     Ticker.Delay(@()disp('--> Dos'), 2);
%     Ticker.Delay(@()disp('Three'), 3);
%     Ticker.Delay(@()disp('--> Tres'), 3);
% 
% Example 3:
%     % Print elapsed time every second.
%     tic
%     handle = Ticker.Repeat(@()fprintf('Elapsed: %.0fs\n', toc), 1);
%     % Stop process after 3 seconds.
%     Ticker.Delay(@()delete(handle), 3);

% 2016-05-12. Leonardo Molina.
% 2019-02-28. Last modified.
classdef Ticker < handle
    properties (Access = private)
        ticker
        queue
        queueId
        callbacks
        intervals
        repetitions
        next
        drop
        exception
        className
        startTime
        intention
    end
    
    properties (Dependent)
        elapsed
    end
    
    properties (Constant)
        dt = 1e-3
    end
    
    methods
        function obj = Ticker()
            % Ticker.Ticker
            % Creates an Ticker which invokes user callbacks after a delay or with a
            % given periodicity.
            
            obj.className = mfilename('class');
            obj.startTime = tic;
            obj.ticker = timer('Name', obj.className, 'TimerFcn', @(~, ~)obj.onStep(), 'ExecutionMode', 'fixedSpacing', 'Period', obj.dt, 'TasksToExecute', Inf, 'BusyMode', 'drop', 'StopFcn', @(~, ~)obj.onSync());
            obj.setup();
        end
        
        function delete(obj)
            if isobject(obj.ticker) && isvalid(obj.ticker)
                obj.intention = 'stop';
                stop(obj.ticker);
                delete(obj.ticker);
            end
        end
        
        function handle = delay(obj, callback, delay, drop)
            % handle = Ticker.delay(callback, delay)
            % Invoke a callback after the given delay. Output handle is a 
            % reference to this process.
            % See also Callbacks.repeat.
            
            if nargin < 4
                drop = true;
            end
            handle = obj.repeat(callback, delay, 1, drop);
        end
        
        function handle = repeat(obj, callback, interval, repetitions, drop)
            % handle = Ticker.repeat(callback, interval, repetitions)
            % Invoke a callback a number of times, with the given
            % periodicity. Repetitions defaults to infinity.
            % Output handle is a reference to this process.
            % See also Callbacksstop, Callbacks.invoke.
            
            if nargin < 4
                repetitions = Inf;
            end
            if nargin < 5
                drop = true;
            end
            id = numel(obj.queue) + 1;
            handle = Ticker.Handle(obj, id);
            obj.queue(id).interval = interval;
            obj.queue(id).repetitions = repetitions;
            obj.queue(id).next = obj.elapsed + interval;
            obj.queue(id).drop = drop;
            obj.queue(id).callback = callback;
            obj.intention = 'resume';
            stop(obj.ticker);
        end
        
        function stop(obj, id)
            % Ticker.stop()
            % Stop processes.
            
            if nargin == 1
                for id = 1:numel(obj.queue)
                    obj.stop(id);
                end
            else
                if id > 0
                    if id <= numel(obj.repetitions)
                        obj.repetitions(id) = 0;
                    elseif id <= numel(obj.queue)
                        obj.queue(id).repetitions = 0;
                    end
                end
            end
        end
        
        function elapsed = get.elapsed(obj)
            elapsed = toc(obj.startTime);
        end
    end
    
    methods (Access = private)
        function onStep(obj)
            periods = max(ceil((obj.elapsed + eps - obj.next) ./ obj.intervals), zeros(size(obj.next)));
            periods(obj.drop) = min(periods(obj.drop), ones(size(obj.drop)));
            due = min(obj.repetitions, periods);
            obj.repetitions = max(obj.repetitions - due, zeros(size(obj.repetitions)));
            ok = true;
            
            c = 1;
            while c <= numel(obj.callbacks) && ok
                d = 1;
                while d <= due(c) && ok
                    try
                        obj.callbacks{c}();
                    catch e
                        ok = false;
                        obj.ticker.TasksToExecute = 1;
                        obj.exception = e;
                        obj.intention = 'error';
                    end
                    d = d + 1;
                end
                if due(c) > 0 && obj.repetitions(c) > 0
                    obj.next(c) = obj.next(c) + obj.intervals(c);
                end
                c = c + 1;
            end
        end
        
        function onSync(obj)
            switch obj.intention
                case 'error'
                    error(Tools.exceptionToString(obj.exception));
                    obj.setup();
                case 'resume'
                    for id = obj.queueId:numel(obj.queue)
                        obj.intervals(id) = obj.queue(id).interval;
                        obj.repetitions(id) = obj.queue(id).repetitions;
                        obj.next(id) = obj.queue(id).next;
                        obj.drop(id) = obj.queue(id).drop;
                        obj.callbacks{id} = obj.queue(id).callback;
                    end
                    obj.queueId = numel(obj.queue) + 1;
                    start(obj.ticker);
                case 'stop'
            end
        end
        
        function setup(obj)
            obj.queue = struct([]);
            obj.queueId = 1;
            obj.callbacks = cell(1, 0);
            obj.intervals = zeros(1, 0);
            obj.repetitions = zeros(1, 0);
            obj.next = zeros(1, 0);
            obj.drop = false(1, 0);
            obj.exception = [];
            start(obj.ticker);
        end
    end
    
    methods (Static)
        function handle = Delay(varargin)
            handle = Ticker.Instance().delay(varargin{:});
        end
        
        function Delete()
            delete(Ticker.Instance());
        end
        
        function instance = Instance()
            if Global.contains('Ticker') && isvalid(Global.get('Ticker'))
                instance = Global.get('Ticker');
            else
                instance = Ticker();
            end
            Global.set('Ticker', instance);
        end
        
        function handle = Repeat(varargin)
            handle = Ticker.Instance().repeat(varargin{:});
        end
        
        function Stop(varargin)
            Ticker.Instance().stop(varargin{:});
        end
    end
end