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

* Syntax: touch filename
* Creates the new empty file filename.
pr touch
	syntax anything(name=fn id=filename)

	gettoken fn rest : fn
	if `:length loc rest' ///
		err 198

	tempname fh
	file open `fh' using `"`fn'"', w
	file close `fh'
end
* Same as -notes _count-, but works in Stata 10.
pr notes_count
	_on_colon_parse `0'
	loc 0 "`s(before)'"
	syntax name(local name=lclname)
	loc 0 "`s(after)'"
	syntax name(name=evar)

	loc note0 : char `evar'[note0]
	if "`note0'" == "" ///
		loc note0 0
	conf integer n `note0'
	c_local `lclname' `note0'
end


/* -------------------------------------------------------------------------- */
					/* tests				*/

pr auto
	qui sysuse auto, clear
end
pr case1, rclass
	auto
	lab data
	* -notes drop _dta- requires variable abbreviation in Stata 10.
	set varabbrev on
	qui note drop _dta in 1/L
	set varabbrev off

	ret sca has_uncommitted = 0
end
pr case2, rclass
	auto

	loc has_uncommitted 1
	* Untracked file
	loc file uncommitted/untracked.txt
	cap touch "`file'"
	conf f "`file'"
	* Untracked directory
	loc dir uncommitted/dir
	cap mkdir "`dir'"
	mata: assert(direxists(st_local("dir")))
	* Staged file
	loc file uncommitted/staged.txt
	cap touch "`file'"
	conf f "`file'"
	!git add "`file'"
	if c(stata_version) >= 13 {
		qui vers `c(stata_version)': stgit
		loc uncommitted "`r(uncommitted_changes)'"
		loc full ""cscript/`file'""
		assert `:list full in uncommitted'
	}

	ret sca has_uncommitted = 1
end
pr case3, rclass
	auto
	qui datasig set
	qui replace foreign = 0
	cap datasig conf
	assert _rc

	ret sca has_uncommitted = 0
end
pr case4, rclass
	auto
	qui dtanotes, creator(case)

	ret sca has_uncommitted = 0
end
pr case5, rclass
	auto
	notes_count count : _dta
	assert `count' == 1
	note _dta: note 2
	set varabbrev on
	qui note drop _dta in 1
	set varabbrev off
	notes_count count : _dta
	assert `count' == 2

	ret sca has_uncommitted = 0
end
pr case6, rclass
	auto
	qui dtanotes, creator(case)
	note _dta: last note

	ret sca has_uncommitted = 0
end
pr case7, rclass
	auto
	qui dtanotes, creator(case) nogit

	ret sca has_uncommitted = 0
end
pr case, rclass
	syntax anything(name=case id=number)

	#d ;
	loc cases
		case1
		case2
		case3
		case4
		case5
		case6
		case7
	;
	#d cr

	if `"`case'"' == "numlist" {
		numlist "1/`:list sizeof cases'"
		ret loc numlist `r(numlist)'
		ex
	}

	conf integer n `case'
	assert inrange(`case', 1, `:list sizeof cases')

	loc cmd : word `case' of `cases'
	assert `:length loc cmd'
	`cmd'
	ret add
	* 1 if added uncommitted files to the repo, 0 if not.
	assert inlist(return(has_uncommitted), 0, 1)

	preserve
	dtanotes drop
	notes_count notes_count : _dta
	* Number of non-dtanotes notes in the dataset in memory
	ret sca notes_count = `notes_count'
	restore

	qui datasig
	ret loc datasignature `r(datasignature)'
end
case numlist
foreach case in `r(numlist)' {
	di
	di as txt "  _________ _________ "
	di as txt " / ___/ __ `/ ___/ _ \"
	di as txt "/ /__/ /_/ (__  )  __/  " as res `case'
	di as txt "\___/\__,_/____/\___/ "
	di

	forv nogit = 0/1 {
		case `case'
		loc notes_before = r(notes_count)
		loc datasig `r(datasignature)'
		loc has_uncommitted = r(has_uncommitted)

		di as txt "dtanotes{hline}"
		loc opt_nogit = cond(`nogit', "nogit", "")
		dtanotes, creator("dtanotes cscript") `opt_nogit'
		di "{hline}"

		* Check the dataset label.
		assert "`:data lab'" == "See notes."

		* Data signature
		qui datasig
		assert "`r(datasignature)'" == "`datasig'"
		qui datasig conf

		* Notes
		notes_count notes_after : _dta
		loc notes_new = cond(`nogit', 4, 7)
		assert `notes_after' == `notes_before' + `notes_new'
		loc n [0-9]
		#d ;
		loc notes
			equals `"Dataset created by "dtanotes cscript"."'
			regex  "Dataset created on `n'`n'[a-z][a-z][a-z]`n'`n'`n'`n' at `n'`n':`n'`n':`n'`n'\."
			equals "Dataset created on computer `:environment computername' by user `c(username)'."
			equals "Data signature: `datasig'"
		;
		#d cr
		if !`nogit' {
			qui vers `c(stata_version)': stgit
			loc sha `r(sha)'
			if c(stata_version) >= 13 {
				loc status = cond(r(is_clean), "", "not ") + "clean"
				loc uncommitted "`r(untracked)' `r(untracked_folders)' `r(uncommitted_changes)'"
				loc uncommitted : list sort uncommitted
			}
			else {
				loc status      unknown
				loc uncommitted unknown
			}
			if `:length loc uncommitted' ///
				loc uncommitted " `uncommitted'"
			#d ;
			loc notes `notes'
				equals "Git SHA of current commit: `sha'"
				equals "Git working tree status: `status'"
				equals `"Git uncommitted changes:`uncommitted'"'
			;
			#d cr
		}
		* Number of columns of `notes'
		loc N_COLS 2
		assert `:list sizeof notes' == `N_COLS' * `notes_new'
		forv i = `=`notes_before' + 1'/`notes_after' {
			loc note : char _dta[note`i']
			* "op" for "operator"
			gettoken op notes : notes
			gettoken s  notes : notes

			mata: assert(regexm(st_local("note"), "^{\* dtanotes 1\.0\.0}"))
			mata: st_local("note", subinstr(st_local("note"), regexs(0), "", 1))
			if "`op'" == "equals" {
				assert `"`note'"' == `"`s'"'
			}
			else if "`op'" == "regex" {
				assert regexm(`"`note'"', `"^`s'$"')
			}
			else {
				err 9
			}
		}

		* Clean up the uncommitted files.
		if `has_uncommitted' {
			assert `case' == 2
			erase uncommitted/untracked.txt
			rmdir uncommitted/dir
			!git reset HEAD uncommitted/staged.txt
			erase uncommitted/staged.txt
		}

		* Test -dtanotes drop-.
		dtanotes drop
		notes_count count : _dta
		assert `count' == `notes_before'
	}
}

rcof `"noi dtanotes, creator("")"' == 198


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
