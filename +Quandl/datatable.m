function output = datatable(table_code, varargin)

  MAX_REQ_LEN = 300;
  % Parse input.
  p = inputParser;
  p.KeepUnmatched = true;
  
  p.addRequired('table_code');
  p.parse(table_code,varargin{:});
  unmatched_struct = p.Unmatched;
  out_table = table;
  
  if length(fieldnames(unmatched_struct)) > 0
    params  = containers.Map(fieldnames(p.Unmatched), struct2cell(p.Unmatched), 'UniformValues', false);
    pkeys   = keys(params);
    pvalues = values(params);
    for i = 1:length(pkeys)
      pvalue_len = length(pvalues{i});
      if pvalue_len > MAX_REQ_LEN & ~ischar(pvalues{i})
        for j = 0:floor(length(pvalues{i})/MAX_REQ_LEN)
          these_values = pvalues{i};
          scan_keys = varargin(1:2:length(varargin));
          idx = find(strcmp(scan_keys, pkeys{i}));
          varargin{idx*2} = these_values((j*MAX_REQ_LEN + 1):min((j+1)*MAX_REQ_LEN, pvalue_len));
          response = Quandl.datatable(table_code, varargin{:});
          out_table = vertcat(out_table, response);
          %
        end
      end
    end
  else
    % params = containers.Map('ValueType', 'any');
    params = containers.Map();
  end
  if sum(size(out_table) == [0 0]) == 2
    api_path = strcat('datatables/', table_code, '.csv');
    response = Quandl.api(api_path, 'params', params, 'version', 'v3');
    tempfile_name = tempname;
    fileID = fopen(tempfile_name,'w');
    fprintf(fileID,response);
    fclose(fileID);
    out_table = readtable(tempfile_name);
  end

  output = out_table;

end