What?
=====

There are many snippet tools around, I love pastie.org and have on and off used
many others.  The problem is they are all web based and as with some of my other
recent tools I am just not web based.

Additionally these tend to be hosted elsewhere, closed source and for something
like a paste tool I really want to be able to hack on it.

There are many self hosted ones with awesome features but I couldn't find one in
Ruby - see my earlier comment about being able to hack on it.  This is a non
functional requirement that I could not find met in any other tool so I wrote
one.

This code snippet tool is different:

 * You self host it
 * It is strictly single user
 * Its data files live in your home directory in ~/.snipper
 * You can only add/edit/remove snippets through the CLI
 * You can only search for snippets on the CLI
 * The web component is just a pure static set of files, you could host them anywhere

These are its goals, do not ask about a web interface, do not send me pull
requests about any kind of way to maintain the snippets through the web or about
multi user support etc, this is not that paste service.

As the code stands now is *very* early days, it really is just a few idle hours
of hacking to get here.  I want to make the HTML output configurable and bunch
of other things and will do so as time goes by and I use it more.  Early
adopters and feedback welcome.

A screenshot of a snippet is in the example directory of the git repo

Installation?
=============

You need to get http://pygments.org/ on your system, I am not going to cover how
to do this.

Create a directory in your home directory called *~/.snipper* and place a config
file called *~/.snipper/config.yml* in it along these lines:

    ---
    :grep: grep --color=auto -riHn -C 2 '%Q%' *
    :baseurl: http://yoursite.com/prefix
    :default_syntax: ruby
    :public_target_dir: /where/your/site/lives
    :theme: monokai
    :dark_theme: true

The *public_target_dir* is where the static HTML will be built, this could
presumably even be a dropbox folder so your machine do not need to be always on,
you can just (ab)use their shared folder urls.

Create the *public_target_dir* and do something like:

    $ mkdir /where/your/site/lives/css
    $ for i in `pygmentize -L styles|grep '^\*'|sed -r "s%(\\* |:)%%g"`
      do
        pygmentize -S $i -f html > /where/your/site/lives/css/$i.css
      done

This creates the CSS for every Pygments theme that you configure in the
*config.yml*

Now install the snippet gem :

    $ export GEM_HOME=/home/you/.gem
    $ PATH=$PATH:/home/you/.gem/bin
    $ gem install snipper

Copy the additional css for the page background :

    $ cp ~/.gem/gems/snipper-*/css/*.css /where/your/site/lives/css/

And you're good to go.

Basic Usage?
============

Everything you do with snippets you do from the command line.

Adding a new snippet
--------------------

    $ cat test.txt|snipper
    http://baseurl/123

You have a new snippet and the URL is based on your config, the snippet id is
123.  The snippet has one file in it.

You can add a 2nd file to the snippet, lets say this is a Perl file

    $ cat test.pl|snipper 123 -l perl
    http://baseurl/123

You could also create a new snippet with multiple files in one go:

    $ snipper foo.pl foo.rb
    http://baseurl/124

In this case it will guess from the file extensions that they are Ruby and Perl
files

Editing a snippet
-----------------

Editing snippets is done using your text editor of choice, vim unless you set
EDITOR in your shell.

    $ snipper e 124
    # edit your files
    http://baseurl/124

When you edit it will simply pass the list of files to edit in a row to your
editor, edit, save move to the next one will your done or quit your editor mid
way through that's totally up to you.

If you zero a file that file will be removed from the snippet.

Snippets can have some meta data associated with them, you'll notice when you
open one there might be a few header lines like:

    ## description: foo
    ## lang: perl

    snippet here

You can tweak descriptions, languages etc there.  There's a pastie.org inspired
shortcut for descriptions:

    ## your description here

    snippet here

Once you save it the static html gets rebuilt and you're shown the URL again.

Deleting a snippet
------------------

Deleting is simple, this removes the source snippet and the static html

    $ snipper d 124
    Removing /home/you/.snipper/snippets/124
    Removing /where/your/site/lives/124

Searching for snippets
----------------------

Searching is done by default with grep, you can configure that though, by
default it will do grep colors and all that.

    $ snipper s ruby
    1/1-1-
    1/1:2:require 'rubygems'
    1/1-3-require 'uv'
    1/1-4-require 'optparse'
    --
    3/2-50-                syntax = lexer.name
    3/2-51-              else
    3/2:52:                syntax = Config[:default_syntax] || "ruby"
    3/2-53-              end
    3/2-54-            end

The numbers is from grep but this basically means it found matches in snippets 1
and 3.  In snippet 1 the match was in the 1st file and for snippet 3 it was in
the 2nd file contained in that snippet.

Viewing snippets on the CLI
---------------------------

You can view a snippet easily, this just cats them into your PAGER

    $ snipper v 124
    # less is run with your snippet visible

Seeing supported languages
--------------------------

You can see what Pygments support by just running:

    $ snipper -L
    Pygments version 1.4, (c) 2006-2008 by Georg Brandl.

    Lexers:
    ~~~~~~
    * Cucumber, cucumber, Gherkin, gherkin:
        Gherkin (filenames *.feature)
    etc
    etc
    etc

Rebuild the gem
===============

In the root folder of the project :

    rake gem

You should find the gem in the subfolder *pkg*.

Contact?
========

R.I.Pienaar / rip@devco.net / @ripienaar / http://devco.net/

