/* Syntax:

	dtanotes, creator()

Adds useful metadata as dataset notes. Specify the name of
the creating do-file, etc. to option -creator()-.

	dtanotes drop

Drops -dtanotes- dataset notes.
*/
pr dtanotes
	vers 10.1

	gettoken subcmd rest : 0

	define_globals

	if `"`subcmd'"' == "drop" {
		drop_notes `rest'
	}
	else {
		add_notes `0'
	}

	drop_globals
end

pr define_globals
	syntax
	gl DTANOTES_VERSION 1.0.0
end

pr drop_globals
	syntax
	foreach suffix in VERSION {
		gl DTANOTES_`suffix'
	}
end

pr add_note
	note: {* dtanotes $DTANOTES_VERSION}`0'
end

pr add_notes
	syntax, creator(str) [NOGIT]

	drop_notes

	lab data "See notes."

	loc creator "`"`creator'"'"
	loc creator : list clean creator
	add_note Dataset created by `creator'.
	loc date : di %td date(c(current_date), "DMY")
	add_note Dataset created on `date' at `c(current_time)'.
	add_note Dataset created on computer `:environment computername' ///
		by user `c(username)'.

	qui datasig set, reset
	add_note Data signature: `r(datasignature)'

	if "`nogit'" == "" {
		vers `c(stata_version)': qui stgit
		if c(stata_version) >= 13 ///
			loc status = cond(r(is_clean), "", "not ") + "clean"
		else ///
			loc status unknown
		add_note Git SHA of last commit: `r(sha)'
		add_note Git working tree status: `status'
	}

	note renumber _dta
	note _dta
end

pr drop_notes
	syntax

	lab data

	loc n : char _dta[note0]
	cap conf n `n'
	if _rc ///
		ex
	forv i = 1/`n' {
		loc note : char _dta[note`i']
		mata: if (regexm(st_local("note"), "^{\* dtanotes .*}")) ///
			st_global("_dta[note`i']", "");;
	}
end
