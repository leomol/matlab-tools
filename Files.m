classdef Files
    methods (Static)
        function fid = open(path, varargin)
            folder = fileparts(path);
            if exist(folder, 'dir') ~= 7
                mkdir(folder);
            end
            fid = fopen(path, varargin{:});
        end
    end
end