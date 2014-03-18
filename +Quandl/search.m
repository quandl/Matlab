function output = search(query, varargin)

    % Parse input.
    p = inputParser;
    p.addRequired('query');
    p.addOptional('page',1);
    p.addOptional('source','');
    p.addOptional('silent',false);
    p.addOptional('authcode',Quandl.auth());
    p.parse(query,varargin{:})
    params = containers.Map();
    params('page') = int2str(p.Results.page);
    source = p.Results.source;
    if not(strcmp(source, ''))
        params('source_code') = source;
    end
    silent = p.Results.silent;
    authcode = p.Results.authcode;
    if size(authcode) > 0
        params('auth_token') = authcode
    end
    params('query') = regexprep(query, ' ', '+');
    path = 'datasets.xml';
    output = Quandl.api(path, 'params', params);

end
