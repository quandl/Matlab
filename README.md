MATLAB-package
=========

This is Quandl's MATLAB Package

License: MIT

For more information please contact raymond@quandl.com

## Installation ##



Download the folder "+Quandl" into the directory of your choice. Then within MATLAB go to file >> Set path... and add the directory containing "+Quandl" to the list (if it isn't already). That's it.

Two things to note, the '+' in "+Quandl" is important in the folder name. It tells Matlab to recognize get.m and auth.m as part of the Quandl package. Secondly, make sure you don't add the "+Quandl" folder in set path. You should be adding the folder that contains it.

### Dependencies ###

This package now REQUIRES urlread2. It can be found [here](http://www.mathworks.com/matlabcentral/fileexchange/35693-urlread2).

Unzip the package and place it in the same directory as +Quandl in the folder +urlread2.

## Usage ##

Once you've found the data you'd like to load into MATLAB on Quandl, copy the Quandl code from the description box and past it into the function.

    >> data = Quandl.get('NSE/OIL');

To extend your access to the Quandl API, use your api key. To do this sign into your account (or create one) and go to [account settings page](https://www.quandl.com/account/api). Then copy your api key next time you call the function:

    >> Quandl.api_key('yourauthenticationtoken');

Subsequently when you call:

    >> data = Quandl.get('NSE/OIL');

MATLAB will remember your authentication token for the remainder of the session.


### Parameters ###

* Date truncation: `mydata = Quandl.get('NSE/OIL', 'start_date','yyyy-mm-dd','end_date','yyyy-mm-dd');`
* Frequency Change: `mydata = Quandl.get('NSE/OIL", 'collapse','annual');` ("weekly"|"monthly"|"quarterly"|"annual")
* Transformations: `mydata: = Quandl.get('NSE/OIL','transformation','rdiff');` ("diff"|"rdiff"|"normalize"|"cumulative")
* Return only n number of rows: `mydata = Quandl.get('NSE/OIL','rows',5);`


## Available Data Types ##
There are four options for which datatype you would like your data returned as, you choose your type as follows:
	
	Quandl.get('NSE/OIL','type','ts')

* **Timeseries (default)**: returns a timeseries if only 1 column in data, tscollection if more. `('type','ts')`
* **Financial timeseries** :`('type','fints')`
* **CSV string**: `('type','ASCII')`
* **DataMatrix**: `('type','data')`
* **Cell Strings**: `('type','cellstr')`

As well a cell string array is returned with the headers. The syntax is as follows:

    output = Quandl.get('NSE/OIL','type','fints')
    [output headers] = Quandl.get('NSE/OIL','type','fints')


## Examples ##

    >> data = Quandl.get('NSE/OIL','collapse','monthly');
    >> ts = data.Open;
    >> ts.TimeInfo.Format = 'yyyy-mm';
    >> plot(ts);

## Datatables ##

To access datatables from the datatables api, you can use the Quandl.datatables function:

    data = Quandl.datatable('ZACKS/EE')

It returns data in a table.

### Parameters ###

Parameters are specific to each datatable. This datatable's filter parameters are `ticker`, `per_type`, `per_end_date` and `qopts.columns`. The following function call returns the columns, per_end_date, per_type and eps_meant_est for all rows which ticker = AAPL.

    data = Quandl.datatable('ZACKS/EE', 'ticker', 'AAPL', 'qopts.columns', {'per_end_date', 'per_type', 'eps_mean_est'})

This call returns all data for Apple and Microsoft:

    data = Quandl.datatable('ZACKS/EE', 'ticker', {'AAPL', 'MSFT'})

## ALPHA ##

You can now search inside the Matlab Console

    >> Quandl.search('crude oil');
    >> Quandl.search('crude oil', 'results', 10, 'page', 3);

It is currently in **ALPHA** and only returns an xml object to the top node of the query results.

## Additional Resources ##
    
More help can be found at [Quandl](https://www.quandl.com) in our [API](https://www.quandl.com/docs/api) docs.
