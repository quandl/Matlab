function output = get(path, varargin)
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
  params('request_version') = '1.0';

  
  url = strcat('http://www.quandl.com/api/', version, '/', path, '?');
  param_keys = params.keys;
  param_values = params.values;
  for i = 1:length(params.keys)
    url = strcat(url, '&', param_keys{i}, '=', param_values{i});
  end
  if length(regexp(path, '.csv'))
    output = urlread(url);
  elseif length(regexp(path, '.xml'))
    output = xmlread(url);
  end
end