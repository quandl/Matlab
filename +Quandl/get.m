% Package: Quandl
% Function: get
% Pulls data from the Quandl API.
% Inputs:
% Required:
% code - Quandl code of dataset wanted. String.
% Optional:
% start_date - Date of first data point wanted. String. 'yyyy-mm-dd'% Package: Quandl
% Function: get
% Pulls data from the Quandl API.
% Inputs:
% Required:% Package: Quandl
% Function: get
% Pulls data from the Quandl API.
% Inputs:
% Required:
% code - Quandl code of dataset wanted. String.
% Optional:
% start_date - Date of first data point wanted. String. 'yyyy-mm-dd'
% end_date - Date of last data point wanted. String. 'yyyy-mm-dd'
% transformation - Type of transformation applied to data. String. 'diff','rdiff','cumul','normalize'
% collapse - Change frequency of data. String. 'weekly','monthly','quarterly','annual'
% rows - Number of dates returned. Integer.
% type - Type of data to return. Leave blank for time series. 'raw' for a cell array.
% api_key - Api key used for continued API access. String.
% Returns:
% If type is blank or type = 'ts'
% timeseries - If only one time series in the dataset.
% tscollection - If more than one time series in the dataset.
% Type = 'fints'
% financial time series
% type = ASCII
% raw csv string
% type = data
% data matrx with date numbers

function [output headers] = get(code, varargin)
    % Parse input.
    p = inputParser;
    p.addRequired('code');
    p.addOptional('start_date',[]); % To be deprecated
    p.addOptional('trim_start',[]); % To be deprecated
    p.addOptional('end_date',[]);
    p.addOptional('trim_end',[]);
    p.addOptional('transformation',[]);
    p.addOptional('collapse',[]);
    p.addOptional('rows',[]);
    p.addOptional('type', 'ts');
    p.addOptional('api_key',Quandl.api_key());
    p.addOptional('sort_order', 'desc');
    p.parse(code,varargin{:})
    start_date = p.Results.start_date;
    end_date = p.Results.end_date;
    if size(start_date) == 0
        start_date = p.Results.trim_start;
    end
    if size(end_date) == 0
        end_date = p.Results.trim_end;
    end
    transformation = p.Results.transformation;
    collapse = p.Results.collapse;
    rows = p.Results.rows;
    type = p.Results.type;
    [met, missing] = Quandl.dependencies();
    if ~met && ismember(type, missing)
        switch type
        case 'ts'
            error_msg = 'This output type requires the Econometric Toolbox.';
        end
        error('Quandl:Depenency', strcat(error_msg, ' Please see http://www.quandl.com/help/matlab for more information, or pick another output type.'));
    end

    api_key = p.Results.api_key;
    params = containers.Map();
    if strcmp(class(code), 'char') || (strcmp(class(code), 'cell') && prod(size(code)) == 1)
        if strcmp(class(code), 'cell')
            code = code{1};
        end
        if regexp(code, '.+\/.+\/.+')
            code = regexprep(code, '\/(?=[^\/]+$)', '.');
        end
        if regexp(code, '\.')
            col = code(regexp(code, '(?<=\.).+$'):end);
            code = regexprep(code, '\..+$', '');
            params('column') = num2str(col);
        end
        path = strcat('datasets/', code, '.csv');
    elseif strcmp(class(code), 'cell') 
        error('Quandl:Deprecated', 'Only one time series may be queried for at a time.');
    end
    params('sort_order') = p.Results.sort_order;
    if strcmp(type, 'ts')
        params('sort_order') = 'desc';
    end
    % string
    % Check for authetication token in inputs or in memory.
    if size(api_key) == 0
        'It would appear you arent using an authentication token. Please visit http://www.quandl.com/help/matlab or your usage may be limited.'
    else
        params('api_key') = api_key;
    end
    % Adding API options.
    if size(start_date)
        params('trim_start') = datestr(start_date, 'yyyy-mm-dd');
    end
    if size(end_date)
        params('trim_end') = datestr(end_date, 'yyyy-mm-dd');
    end
    if size(transformation)
        params('transformation') = transformation;
    end
    if size(collapse)
        params('collapse') = collapse;
    end
    if size(rows)
        params('rows') = num2str(rows);
    end

    api_response = Quandl.api(path, 'params', params);
    col_names = api_response.Properties.VariableNames;
    % Parsing input to be passed as a time series.

    if strcmp(type, 'table')
        output = api_response;
        return
    elseif strcmp(type, 'ts')
        ts = timeseries(table2array(api_response(:, col_names{2})), char(table2array(api_response(:,col_names{1}))), 'name', col_names{2});
        if length(col_names) > 2
            output = tscollection({ts},'name',code);
            for i = 2:(length(col_names)-1)
                output = addts(output,table2array(api_response(:,col_names{i+1})),col_names{i+1});
            end
        else
            output = ts;
        end
    elseif strcmp(type, 'ttable')
        output = table2timetable(api_response);
        return
    elseif strcmp(type, 'data')
        datenum_data = datenum(table2array(api_response(:, col_names{1})));
        float_data = table2array(removevars(api_response, col_names{1}));
        output = [datenum_data float_data];
        return
    else
        error('Invalid format');
    end
end

