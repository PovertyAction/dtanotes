Contributing
============

Please contribute to `dtanotes` through issues or pull requests.

Certification script
--------------------

The [certification script](http://www.stata.com/help.cgi?cscript) of `dtanotes` is [`cscript/dtanotes.do`](/cscript/dtanotes.do). If you are new to certification scripts, you may find [this](http://www.stata-journal.com/sjpdf.html?articlenum=pr0001) Stata Journal article helpful.

When contributing code, adding associated cscript tests is much appreciated.

Stata environment
-----------------

Follow these steps to set up your Stata environment for `dtanotes` development.

### User-written programs and ado-path

Type the following in Stata to install SSC packages used in `dtanotes` itself or the cscript:

```stata
ssc install fastcd
```

Now set up `fastcd` to run on your computer as follows:

```stata
* Change the working directory to the location of GitHub/dtanotes on your
* computer.
cd ...
c cur dtanotes
```

After this, the command `c dtanotes` will change the working directory to `GitHub/dtanotes`.

`fastcd` is the name of the SSC package, not the command itself; the command is named `c`. To change the working directory, type `c` in Stata, not `fastcd`. To view the help file, type `help fastcd`, not `help c`.

Finally, add `dtanotes` to your ado-path:

```stata
c dtanotes
adopath ++ `"`c(pwd)'"'
```

You may wish to place the above lines in your [`profile.do`](http://www.stata.com/support/faqs/programming/profile-do-file/) as follows:

```stata
local curdir "`c(pwd)'"
c dtanotes
adopath ++ `"`c(pwd)'"'
cd `"`curdir'"'
```
