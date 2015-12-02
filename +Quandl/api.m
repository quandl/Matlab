function output = api(path, varargin)
  % Parse input.
  p = inputParser;
  p.addRequired('path');
  p.addOptional('version','v1');
  p.addOptional('http','GET');
  p.addOptional('params',containers.Map());
  p.parse(path,varargin{:})
  path = p.Results.path;
  version = p.Results.version;
  http = p.Results.http;
  params = p.Results.params;

  params('request_source') = 'matlab';
  params('request_version') = '1.1.2';

  
  url = strcat('https://www.quandl.com/api/', version, '/', path, '?');
  
  param_keys = params.keys;
  param_values = params.values;
  for i = 1:length(params.keys)
    url = strcat(url, '&', param_keys{i}, '=', param_values{i});
  end

  if length(regexp(path, '.csv'))
    [response, extras] = urlread2.urlread2(url);
  elseif length(regexp(path, '.xml'))
    output = xmlread(url);
    return
  end
  
  status_regex = regexp(cellstr(extras.allHeaders.Response), '200', 'match');
  if isempty(status_regex{1})
    error('Quandl:api', response)
  end
  output = response;
end
