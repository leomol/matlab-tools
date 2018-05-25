classdef Handle
    properties (Access = private)
        ticker
    end
    
    methods
        function obj = Handle(ticker)
            obj.ticker = ticker;
        end
        
        function delete(obj)
            Timers.delete(obj.ticker);
        end
    end
end