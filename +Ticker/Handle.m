classdef Handle
    properties (Access = private)
        ticker
        id
    end
    
    methods
        function obj = Handle(ticker, id)
            obj.ticker = ticker;
            obj.id = id;
        end
        
        function delete(obj)
            obj.ticker.stop(obj.id);
        end
    end
end