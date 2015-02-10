/* Syntax:

	dtanotes, creator()

Adds useful metadata as dataset notes. Specify the name of
the creating do-file, etc. to option -creator()-.

	dtanotes drop

Drops -dtanotes- dataset notes.
*/
pr dtanotes
	vers 12.1

	gettoken subcmd rest : 0

	if `"`subcmd'"' == "drop" {
		Drop `rest'
	}
	else {
		Add `0'
	}
end

pr Note
	note: {* dtanotes}`0'
end

pr Add
	syntax, creator(str)

	dtanotes drop

	lab data "See notes."

	loc creator "`"`creator'"'"
	loc creator : list clean creator
	Note Dataset created by `creator'.
	loc date : di %td date(c(current_date), "DMY")
	Note Dataset created on `date' at `c(current_time)'.
	Note Dataset created on computer `:environment computername' ///
		by user `c(username)'.

	qui datasig set, reset
	Note Data signature: `r(datasignature)'

	vers `c(stata_version)': qui stgit
	if c(stata_version) >= 13 ///
		loc status = cond(r(is_clean), "", "not ") + "clean"
	else ///
		loc status unknown
	Note Git SHA of last commit: `r(sha)'
	Note Git working tree status: `status'

	note renumber _dta
	note _dta
end

pr Drop
	lab data

	loc n : char _dta[note0]
	cap conf n `n'
	if _rc ///
		ex
	forv i = 1/`n' {
		loc note : char _dta[note`i']
		mata: if (regexm(st_local("note"), "^{\* dtanotes}")) ///
			st_global("_dta[note`i']", "");;
	}
end
