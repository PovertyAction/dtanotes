* -dtanotes- cscript

* -version- intentionally omitted for -cscript-.

* 1 to execute profile.do after completion; 0 not to.
local profile 1


/* -------------------------------------------------------------------------- */
					/* initialize			*/

* Check the parameters.
assert inlist(`profile', 0, 1)

* Set the working directory to the dtanotes directory.
c dtanotes
cd cscript

cap log close dtanotes
log using dtanotes, name(dtanotes) s replace
di "`:environment computername'"
di "`c(username)'"

clear
if c(stata_version) >= 11 ///
	clear matrix
clear mata
set varabbrev off
set type float
vers 10.1: set seed 706485430
set more off

cd ..
adopath ++ `"`c(pwd)'"'
cd cscript

timer clear 1
timer on 1

* Preserve select globals.
loc FASTCDPATH : copy glo FASTCDPATH

cscript dtanotes adofile dtanotes

* Restore globals.
glo FASTCDPATH : copy loc FASTCDPATH


/* -------------------------------------------------------------------------- */
					/* tests				*/

// ...


/* -------------------------------------------------------------------------- */
					/* finish up			*/

cd ..

timer off 1
timer list 1

if `profile' {
	cap conf f C:\ado\profile.do
	if !_rc ///
		run C:\ado\profile
}

timer list 1

log close dtanotes
