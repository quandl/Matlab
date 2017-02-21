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
        case 'fints'
            error_msg = 'This output type requires the Financial Toolbox.';
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
        code = regexprep(code, '/', '.');
        for i = 2:length(code)
            code{i} = strcat(',', code{i});
        end
        params('columns') = [code{:}];
        path = 'multisets.csv';
    end
    params('sort_order') = p.Results.sort_order;
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
    % Loading csv and checking if it exists.
    % try
    csv = Quandl.api(path, 'params', params);
    % catch
    %     error('Quandl:code','Code does not exist.')
    % end
    % Parsing input to be passed as a time series.
    csv = strread(csv,'%s','delimiter','\n');
    pattern = '("[^"]*"|[^,]*)';
    try
        headers = regexp(csv{1}, pattern, 'match');
    catch exception
        error('Quandl returned an empty CSV file. (Invalid Code Likely)');
    end
    
    rowz = length(csv)-1;
    if rowz == 0
        error('Dataset is empty')
    end
    columns = length(headers);
    if columns > 1001 && length(regexp(string,'multisets','match')) > 0
        'Maximum column length for multisets is 1000 columns.'
        headers = headers(1:101);
    end

    for i = 1:rowz
        temp = textscan(csv{i+1}(12:end), '%f', 'Delimiter',',');
        temp = temp{1};
        temp = transpose(temp);
        if strcmp(csv{i+1}(end),',') %Matlab does not catch delimiters at end of line.
            temp = [temp, NaN];
        end
        if i == 1
            DATE = csv{i+1}(1:10);
        else
            DATE = char(DATE,csv{i+1}(1:10));
        end
        data(i,:) = temp;
    end
    DATE = cellstr(DATE);
    temp = size(type);
    % Creating time series from raw data.
    if temp(1) == 0 || strcmp(type, 'ts')
        ts = timeseries(data(:,1),DATE,'name',headers{2});
        if columns > 2
            output = tscollection({ts},'name',code);
            for i = 2:(columns-1)
                output = addts(output,flipud(data(:,i)),headers{i+1});
            end
        else
            output = ts;
        end
    elseif strcmp(type, 'cell') | strcmp(type, 'cellstr')
        % output = [transpose(headers);DATE, num2cell(data)];
        % output = [transpose(headers);DATE, data];
        output = [DATE num2cell(data)];

    elseif strcmp(type, 'table')
        output = cell2table([DATE num2cell(data)], 'VariableNames', matlab.lang.makeValidName(headers));

    elseif strcmp(type, 'ASCII')
        output = csv;
    elseif strcmp(type, 'fints')
        sanitized_headers = regexprep(regexprep(headers(2:end),' ','_'), '[^A-Z0-9a-z_]', '')
        for i = 1:length(sanitized_headers)
            sanitized_header = sanitized_headers{i};
            results = regexp(sanitized_header, '^(\d+)(.+)', 'tokens');
            if length(results) > 0
                sanitized_header = [results{1}{2} results{1}{1}];
            end
            sanitized_headers{i} = sanitized_header;
        end
        output = fints(datenum(DATE), data, sanitized_headers);
    elseif strcmp(type, 'data')
        output = [datenum(DATE) data];
    else
        error('Invalid format');
    end
end

