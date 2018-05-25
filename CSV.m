% 2015-10-06. Leonardo Molina.
% 2018-05-03. Last modified.
classdef CSV
    methods (Static)
        function csv = load(filename)
            % csv = load(filename) - read file contents, split by commas and 
            % return as a cell array.
            
            csv = textscan(fileread(filename), '%s', 'Delimiter', ',');
            csv = csv{1};
        end
        
        function data = parse(csv, selection, varargin)
            % data = CSV.parse(csv, selection, label1, label2, ...)
            % Return a cell array of strings from a csv array with literal matches.
            % selection: Index of columns to extract relative to label1, e.g. [-1, 3, 4]
            % 
            % For example:
            %   data = {'0', 'type1', '0', '0', ...
            %           'type2', '222', ...
            %           '1', 'type1', '1', '1', ...
            %           'type2', '333', ...
            %           '2', 'type1', '2', '2'};
            %   str2double(CSV.parse(data, [-1 1 2], 'type1')) %-->
            %     [0 0 0
            %      1 1 1
            %      2 2 2]
            %   CSV.parse(data, 1, 'type2') %-->
            %     {'222'
            %      '333'}

            csv = transpose(csv(:));
            selection = selection(:);
            labels = varargin;

            % Flag matches.
            matches = true(size(csv));
            for l = 1:numel(labels)
                if ~isempty(labels{l})
                    matches = matches & ismember(circshift(csv, 1 - l), labels{l});
                end
            end

            % Add adjacent columns.
            index = repmat(find(matches), numel(selection), 1);
            index = bsxfun(@plus, index, selection);

            if isempty(index)
                % No matches found.
                data = repmat({''}, 0, numel(selection));
            else
                % Result may become bigger than csv.
                last = max(index(:, end));
                csv(end + 1:last) = deal({''});
                % Remove overlaps.
                data = reshape(csv(index), size(index));
                [~, k] = unique(index(end:-1:1));
                k = numel(index) - k + 1;
                k = setdiff(1:numel(index), k);
                data(k) = {''};
                data = data';
            end
        end
    end
end