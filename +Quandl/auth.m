function [outputcode] = auth(varargin)
    % Parse input.
    p = inputParser;
    p.addOptional('authcode','',@isstr);
    p.parse(varargin{:})
    authcode = p.Results.authcode;
    persistent auth_token;
    if size(authcode) ~= 0
        Quandl.api_key(authcode);
    end
    outputcode = Quandl.api_key();
end

