function [outputcode] = api_key(varargin)
    % Parse input.
    p = inputParser;
    p.addOptional('api_key','',@isstr);
    p.parse(varargin{:})
    local_api_key = p.Results.api_key;
    persistent pers_api_key;
    if size(local_api_key) ~= 0
        pers_api_key = local_api_key;
    end
    outputcode = pers_api_key;
end

