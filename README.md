dtanotes
========

`dtanotes` is a Stata program that adds useful metadata as dataset notes. The latest version is available through SSC: type `ssc install dtanotes` in Stata to install.

Contributing
------------

See the [contributing guide](/CONTRIBUTING.md) for advice on collaborating.

Stata help file
---------------

Converted automatically from SMCL:

```
log html dtanotes.sthlp dtanotes.md
```

The help file looks best when viewed in Stata as SMCL.

<pre>
<b><u>Title</u></b>
<p>
    <b>dtanotes</b> -- Add metadata as dataset notes
<p>
<p>
<a name="syntax"></a><b><u>Syntax</u></b>
<p>
    Add <b>dtanotes</b> notes
<p>
        <b>dtanotes,</b> <b>creator(</b><i>string</i><b>)</b> [<b>nogit</b>]
<p>
<p>
    Drop <b>dtanotes</b> notes
<p>
        <b>dtanotes drop</b>
<p>
<p>
<a name="description"></a><b><u>Description</u></b>
<p>
    <b>dtanotes</b> adds useful metadata as dataset notes:
<p>
        o Creating do-file or process
        o Current date and time
        o Names of computer and user
        o Data signature
        o Git SHA-1 hash of the current commit
        o Git working tree status
        o Git uncommitted changes, including untracked files and directories
<p>
    <b>dtanotes</b> also labels the dataset with <b>"See notes."</b> so that the notes are
    not overlooked.
<p>
    <b>dtanotes drop</b> drops <b>dtanotes</b> notes.
<p>
<p>
<a name="options_dtanotes"></a><b><u>Options for dtanotes</u></b>
<p>
    <b>creator(</b><i>string</i><b>)</b> is required and specifies the name of the do-file or
        process that created the dataset.
<p>
    <b>nogit</b> specifies that <b>dtanotes</b> not add information about a Git repository
        to notes.
<p>
<p>
<a name="remarks"></a><b><u>Remarks</u></b>
<p>
    <b>dtanotes</b> drops previous <b>dtanotes</b> notes before adding new ones.  It resets
    the data signature before adding it to notes.
<p>
    Because <b>dtanotes</b> adds information about a Git repository to notes, the
    SSC program <b>stgit</b> is required. The working directory should be set to the
    repository that contains the code that created the dataset.  If the
    project does not use Git, specify option <b>nogit</b> when adding notes.
<p>
    The GitHub repository for <b>dtanotes</b> is here.
<p>
<p>
<a name="author"></a><b><u>Author</u></b>
<p>
    Matthew White
<p>
    For questions or suggestions, submit a GitHub issue or e-mail
    researchsupport@poverty-action.org.
<p>
<p>
<b><u>Also see</u></b>
<p>
    Help:  <b>[D] notes</b>, <b>[D] datasignature</b>
<p>
    User-written:  <b>stgit</b>
</pre>
