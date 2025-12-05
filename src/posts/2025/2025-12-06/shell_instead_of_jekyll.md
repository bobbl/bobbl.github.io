---
title:  "GitHub pages with a simple shell script instead of Jekyll"
---



After reading Fabien Sanglard's blog post about
[bloated](https://fabiensanglard.net/bloated/index.html) websites, I realised
that I am guilty, too. Using [Jekyll](https://jekyllrb.com/) for building my
little blog implies unnecessary dependencies and waste of computing power.
A simple shell script and [Pandoc](https://pandoc.org/) for converting the
markdown should do the job.
And there are several projects like [bashblog](https://github.com/cfenollosa/bashblog)
or [bic](https://bic.sh/) that use bash to create static blog websites from
markdown. However, I thought that configuring them is more work that writing such
a script from scratch. And I prefer pure POSIX shell scripting over bash
(the b stands for bloated).



What the generator script does
------------------------------

The script recursively descents the `src/` directory and copies the whole tree
with all files to the `dist/` directory. Only markdown files (extension `.md`)
get a special treatment: They are converted to HMTL with Pandoc and a header
and footer in pure HTML are added. To be precise, the relative `href=` 
references in the header and footer have to be adjusted to the directory depth
and there is a little postprocessing to set the title of the HTML page
according to the `title:` tag in the frontmatter of the markdown file (Pandoc
cannot do this).

If the frontmatter contains a `date: YYYY-MM-DD` tag or the file path contains
a date in the form `YYYY-MM-DD`, the page is treated as a blog post and added to
the list of blog posts. When the whole directory tree was copied, a page with
this list, ordered by date is generated. That's all.

This gives maximum flexibility:

  * Any directory structure is possible.
  * Arbitrary HTML pages can be added (they are simply copied).
  * The markdown posts can be placed anywhere within the directory structure.



Legacy Jekyll links
-------------------

Since postings can be put anywhere in the directory tree, it is easy to preserve
the URLs of the deprecated Jekyll pages. You just have to create enough
subdirectories and put your markdown file there. The script will find them and
order them by date automatically 

But I want that even my old posts are in the new directory structure which is
ordered by date. Therefore I added redirects using the
`<meta http-equiv="refresh">` tag:

    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta http-equiv="refresh" content="0; url=https://bobbl.github.io/NEWURL">
        <title>Redirection</title>
      </head>
      <body>
        <p>
          The page has moved to
          <a href="https://bobbl.github.io/NEWURL">
                   https://bobbl.github.io/NEWURL
          </a>. You will be automatically redirected.
        </p>
      </body>
    </html>



Switch from Jekyll to custin build script
-----------------------------------------



