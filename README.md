MATLAB-package
=========

This is Quandl's MATLAB Package

License: GPL-2

For more information please contact raymond@quandl.com

# Installation #

Download the folder "+Quandl" into the directory of your choice. Then within MATLAB go to file >> Set path... and add the directory to the list (if it isn't already). That's it.

It should be noted that the '+' in "+Quandl" is important in the folder name. It tells Matlab to recognize get.m and auth.m as part of the Quandl package.

# Usage #

Once you've found the data you'd like to load into MATLAB on Quandl, copy the Quandl code from the description box and past it into the function.

    >> data = Quandl.get('NSE/OIL');

To extend your access to the Quandl API, use your authentication token. To do this sign into your account (or create one) and go to the API tab under in your account page. Then copy your authentication token next time you call the function:

    >> Quandl.auth('yourauthenticationtoken');

Subsequently when you call:

    >> data = Quandl.get('NSE/OIL');

MATLAB will remember your authentication token for the remainder of the session.


### Parameters ###

* Date truncation: `mydata = Quandl.get('NSE/OIL', 'start_date','yyyy-mm-dd','end_date','yyyy-mm-dd');`
* Frequency Change: `mydata = Quandl.get('NSE/OIL", 'collapse','annual');` ("weekly"|"monthly"|"quarterly"|"annual")
* Transformations: `mydata: = Quandl.get('NSE/OIL','transformation','rdiff');` ("diff"|"rdiff"|"normalize"|"cumulative")
* Return only n number of rows: `mydata = Quandl.get('NSE/OIL','rows',5);`


# Available Data Types #
There are four options for which datatype you would like your data returned as, you choose your type as follows:
	
	Quandl.get('NSE/OIL','type','ts')

* **Timeseries (default)**: returns a timeseries if only 1 column in data, tscollection if more. `('type','ts')`
* **Financial timeseries** :`('type','fints')`
* **CSV string**: `('type','ASCII')`
* **DataMatrix**: `('type','data')`
* **Cell Strings**: `('type','cellstr')''




# Examples #

    >> data = Quandl.get('NSE/OIL','collapse','monthly');
    >> ts = data.Open;
    >> ts.TimeInfo.Format = 'yyyy-mm';
    >> plot(ts);

# Additional Resources #
    
More help can be found at [Quandl](http://www.quandl.com) in our [MATLAB](http://www.quandl.com/help/packages/matlab) and [API](http://www.quandl.com/help/api) help pages.
