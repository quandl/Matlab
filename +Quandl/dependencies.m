function [met, missing] = dependencies(varargin)
    p = inputParser;
    p.addOptional('force',false,@islogical);
    p.parse(varargin{:})
    force = p.Results.force;
    persistent dependencies_met;
    persistent dependencies_missing;
    if size(dependencies_missing) == 0
        dependencies_missing = {};
    end
    if (size(dependencies_met) == 0) | force
        % check dependencies
        dependencies_met = true;
        if ~exist('+urlread2/urlread2.m')
            error('Quandl:Dependency', 'This module requires urlread2. Go to http://www.github.com/quandl/Matlab for more information')
        end
        if ~exist('timeseries')
            dependencies_missing = [ dependencies_missing, 'ts' ];
            dependencies_met = false;
        end
        if ~exist('fints')
            dependencies_missing = [ dependencies_missing, 'fints' ];
            dependencies_met = false;
        end
        
    end

    met = dependencies_met;
    missing = dependencies_missing;
    
end

