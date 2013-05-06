MATLAB-package
=========

This is Quandl's MATLAB Package

License: GPL-2

For more information please contact raymond@quandl.com

# Installation

Download the folder "+Quandl" into the directory of your choice. Then within MATLAB go to file >> Set path... and add the directory to the list (if it isn't already). That's it.

It should be noted that the '+' in "+Quandl" is important in the folder name. It tells Matlab to recognize get.m and auth.m as part of the Quandl package.

# Usage

Once you've found the data you'd like to load into MATLAB on Quandl, copy the Quandl code from the description box and past it into the function.

    >> data = Quandl.get('NSE/OIL');

To extend your access to the Quandl API, use your authentication token. To do this sign into your account (or create one) and go to the API tab under in your account page. Then copy your authentication token next time you call the function:

    >> Quandl.auth('yourauthenticationtoken');

Subsequently if you call:

    >> data = Quandl.get('NSE/OIL');

MATLAB will remember your authentication token for the remainder of the session.

# Examples

    >> data = Quandl.get('NSE/OIL','collapse','monthly');
    >> ts = data.Open;
    >> ts.TimeInfo.Format = 'yyyy-mm';
    >> plot(ts);

# Additional Resources
    
More help can be found at [Quandl](http://www.quandl.com) in our [MATLAB](http://www.quandl.com/help/matlab) and [API](http://www.quandl.com/api) help pages.
