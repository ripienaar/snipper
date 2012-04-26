Overview
========

There are many self hosted snippet tools designed to live on a web page taking
snippets from the web or an API.  As with *gwtf* I live on the CLI and so want a
CLI orientated snippet tool. As with *gwtf* I don't care for getting snippets
from other people it's purely single user.

The overall idea would be that I can maintain snippets in my home directory in
a easily grepable layout but that each snippet action will maintain a simple
website built using static files, no data base, web frontend or anything like
that.  Just simple CLI orientated self hosted single user text snippet tool.
To use it effectively your shell must be on the internet always and have a
dedicated connection.  You could though publish your static site to dropbox
or something similar, it's just files.

It will use http://ultraviolet.rubyforge.org for syntax highlighting

The snippets will live in a directory in your home dir, after each
edit/update/delete a public rendered version of the snippets will be stored in a
docroot as static files

A simple *last 10 snippets* index page should be maintained showing last 10
public snippets

    ~/.snipper
    └── snippets
        ├── 123
        │   ├── 1
        │   ├── 2
        │   └── 3
        └── 124
            └── 1

Search will be done with a simple grep -r over the snippets dir showing a few
lines of match context in PAGER

CLI Concept
===========

    # new snippet
    cat test.pp|snipper
    http://baseurl/123

    # net snippet with puppet syntax
    cat test.pp|snipper -l puppet
    http://baseurl/123

    # add a file to snippet 123
    cat test.pp|snipper 123
    http://baseurl/123

    # edit a snippet, if its multiple files they will be
    # appended to the $EDITOR command line, empty file will
    # delete it from the snippet
    snipper e 123
    http://baseurl/123

    # delete a whole snippet
    snipper rm 123

    # search through snippets using the command defined in grep
    # the example shows 2 snippets, the first is a multi file
    # snippet with the 2nd file matching, 2 lines of context is
    # shown for each line
    snipper s puppet
    123/2-1-baz
    123/2-2-
    123/2:3:puppet foo
    123/2-4-
    123/2-5-bar
    --
    124/1-1-
    124/1:2:puppet blah blah

    # view a snippet
    snipper v 124

    # list of supported languages
    snipper -L

Snippet Layout
==============

All the header fields are optional, the first blank line stops header parsing

    ## description: free form description
    ## syntax: puppet

    text of the snippet

Config
======

YAML file in ~/.snipper/config.yml

    ---
    :public_target_dir: /some/dir
    :default_language: ruby
    :grep: grep --color=auto -riHn -C 2 '%Q%' *
    :baseurl: http://some.site/snipper
    :theme: pastie
    :dark_theme: false
