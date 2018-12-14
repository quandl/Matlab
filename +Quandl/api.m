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

  source_header = matlab.net.http.HeaderField('Request-Source','matlab');
  version_header = matlab.net.http.HeaderField('Request-Version','2.1.0');
  headers = [source_header version_header];

  % headers = [struct('name','Request-Source','value','matlab') struct('name','Request-Version','value','2.1.0')];
  
  if isKey(params, 'api_key')
    headers = [headers matlab.net.http.HeaderField('X-Api-Token',params('api_key'))];
  elseif size(Quandl.api_key()) ~= 0
    params('api_key') = Quandl.api_key();
    headers = [headers matlab.net.http.HeaderField('X-Api-Token',Quandl.api_key())];
  end

  url = strcat('https://www.quandl.com/api/', version, '/', path, '?');
  
  param_keys = params.keys;
  param_values = params.values;
  for i = 1:length(params.keys)
    if ((length(param_values{i}) > 1) & (~strcmp(class(param_values{i}), 'char'))) | strcmp(class(param_values{i}), 'containers.Map')
      p_values = param_values{i};
      if strcmp(class(p_values), 'cell')
        url = strcat(url, '&', param_keys{i}, '=', strjoin(p_values, ','));
      elseif strcmp(class(p_values), 'containers.Map')
        ckeys = keys(p_values);
        cvalues = values(p_values);
        for j = 1:length(ckeys)
          if (length(cvalues{j}) > 1) & (~strcmp(class(cvalues{j}), 'char'))
            url = strcat(url, '&', param_keys{i}, '.', ckeys{j}, '=', strjoin(cvalues{j}, ','));
          else
            url = strcat(url, '&', param_keys{i}, '.', ckeys{j}, '=', cvalues{j});
          end
        end
      end
    else
      url = strcat(url, '&', param_keys{i}, '=', param_values{i});
    end
  end
  url
  if length(regexp(path, '.csv'))
    method = matlab.net.http.RequestMethod.GET;
    request = matlab.net.http.RequestMessage(method, headers);
    response = send(request, url);
  elseif length(regexp(path, '.xml'))
    output = xmlread(url);
    return
  end
  
  if ~strcmp(response.StatusCode, 'OK')
    error('Quandl:api', response.Body.Data.message{1})
  end
  output = response.Body.Data;
  if ~isempty(response.getFields('Cursor_ID'))
    params('qopts.cursor_id') = char(response.getFields('Cursor_ID').Value);
    temp_response = Quandl.api(path, 'params', params, 'http', http, 'version', version);
    output = vertcat(output, temp_response);
    % output = [output, temp_response];
  end
  
end
