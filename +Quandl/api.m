function output = api(path, varargin)
  % Parse input.
  p = inputParser;
  p.addRequired('path');
  p.addOptional('version','v3');
  p.addOptional('http','GET');
  p.addOptional('params',containers.Map());
  p.parse(path,varargin{:});
  path = p.Results.path;
  version = p.Results.version;
  http = p.Results.http;
  params = p.Results.params;
  headers = [struct('name','Request-Source','value','matlab') struct('name','Request-Version','value','2.1.0')];
  
  if isKey(params, 'api_key')
    headers = [headers struct('name', 'X-Api-Token', 'value', params('api_key'))];
  elseif size(Quandl.api_key()) ~= 0
    params('api_key') = Quandl.api_key();
    headers = [headers struct('name', 'X-Api-Token', 'value', Quandl.api_key())];
  end

  url = strcat('https://www.quandl.com/api/', version, '/', path, '?');
  
  param_keys = params.keys;
  param_values = params.values;
  for i = 1:length(params.keys)
    if (length(param_values{i}) > 1) & (~strcmp(class(param_values{i}), 'char'))
      p_values = param_values{i};
      for j = 1:length(p_values)
        url = strcat(url, '&', param_keys{i}, '[]=', p_values{j});
      end
    else
      url = strcat(url, '&', param_keys{i}, '=', param_values{i});
    end
  end

  if length(regexp(path, '.csv'))
    [response, extras] = urlread2.urlread2(url, 'GET', '', headers);
  elseif length(regexp(path, '.xml'))
    output = xmlread(url);
    return
  end
  
  status_regex = regexp(cellstr(extras.allHeaders.Response), '200', 'match');
  if isempty(status_regex{1})
    error('Quandl:api', response)
  end
  if isfield(extras.allHeaders, 'Cursor_ID')
    params('qopts.cursor_id') = char(extras.allHeaders.Cursor_ID);
    params('qopts.exclude_column_names') = 'true';
    temp_response = Quandl.api(path, 'params', params, 'http', http, 'version', version);
    response = sprintf('%s%s',response , temp_response{2:end});
  end
  output = response;
end
