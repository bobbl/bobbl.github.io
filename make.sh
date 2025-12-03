#!/bin/sh


help () {
    echo "Build .html website from markdown files"
    echo
    echo "Usage: $0 <action> ..."
    echo
    echo "Actions"
    echo "  build    Recursively convert markdown to .html files, copy other"
    echo "           files and create index of all posts with a date"
    echo
    echo "Environment variables (with default value)"
    echo "  CONFIG_SRC_PATH=src    directory with source files"
    echo "  CONFIG_DIST_PATH=dist  target directory"
    echo "  CONFIG_TOC=index.html  filename for list of posts"
}

if [ $# -eq 0 ] 
then
    help
    exit 1
fi


# folder for the generated website
CONFIG_DIST_PATH=${CONFIG_DIST_PATH:-dist}

# folder for the source code of the website
CONFIG_SRC_PATH=${CONFIG_SRC_PATH:-src}

# page with the list of the posts
CONFIG_TOC=${CONFIG_TOC:-index.html}




# Add header and footer to .html file
# Adjust path in URLs according to subdir depth
# Set <title> tag in html head
wrap () {
    filename_html="$1"  # full filename with path to .html file to be wrapped
    rel_html="$2"       # relative path of wrapped .html file within
                        # $CONFIG_DIST_PATH directory
    title="$3"          # title of the page

    output="$CONFIG_DIST_PATH/$rel_html"
    down_to_rootdir=$(echo $rel_html | sed 's|[^/]*$|| ; s|[^/]*/|../|g')
    sed "s|href=\"\./|href=\"${down_to_rootdir}|g ;
         s|<title>.*</title>|<title>$title</title>|" top.html > "$output"

    cat "$filename_html" >> "$output"
    cat << HEREDOC >> "$output"
      </div>
    </main>
  </body>
</html>
HEREDOC
}


# Get the value of the frontmatter variable
# $1 file name
# $2 variable name
get_frontmatter_var () {
    sed -n "s/^$2//p" "$1" | head -n1 | sed 's/[^"]*"//; s/"[[:space:]]*$//' 
}


# Remove anything but YYYY-MM-DD from given string
extract_date () {
    echo $1 | sed -n 's/.*\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\).*/\1/p'
}


# Convert markdown post
convert_md () {
    filename_md="$1" # full path of markdown source file
    rel_html="$2"    # relative path within $CONFIG_DIST_PATH with .html extension

    # extract title from header of markdown file
    title=$(get_frontmatter_var "$filename_md" title:)

    # extract date form header of markdown file
    datetime=$(get_frontmatter_var "$filename_md" date:)
    date="$(extract_date $datetime)"
    if [ -z $date ]
    then
        # if date is not given in the header, extract it from filename
        date=$(extract_date $filename_md)
    fi

    # add to table of contents only if a date was found
    if [ -n $date ]
    then
        echo "<a href='$rel_html'>$date&nbsp;&nbsp;$title</a><br>" >> tmp.toc
        echo post: $date $title
    fi

    echo "<h1>$title</h1>" > tmp.html
    pandoc "$filename_md" >> tmp.html
    echo "<p class=\"lastmodified\">$date</p>" >> tmp.html
    wrap tmp.html "$rel_html" "$title"
}


# Go through directories in src folder and convert .md if necessary
recurse_subdir () {
    curpath="$1" # process this directory, recurse into subdirs

    for f in "$curpath"/*
    do
        relative_filename=${f#$CONFIG_SRC_PATH/}

        if [ -d "$f" ]
        then
            mkdir -p "$CONFIG_DIST_PATH/$relative_filename"
            recurse_subdir "$f"
        else
            case "$f" in
                *.md)
                    convert_md "$f" "${relative_filename%.md}.html"
                    ;;
                *)
                    cp "$f" "$CONFIG_DIST_PATH/$relative_filename"
                    ;;
            esac
        fi
    done
}


while [ $# -ne 0 ]
do
    case $1 in
        help)           help ;;

        build)
            rm -f tmp.toc

            recurse_subdir "$CONFIG_SRC_PATH"

            # create index.html as table of contents
            echo "<h1>Articles</h1><p>" > tmp.html
            sort -r  tmp.toc >> tmp.html
            echo "</p>" >> tmp.html
            wrap tmp.html "$CONFIG_TOC" "bob[bl]og"
            ;;

        clean)
            rm -rf "$CONFIG_DIST_PATH/"
            ;;

        *)
            echo "Unknown action $1. Stop."
            exit 1
            ;;
    esac
    shift
done

# SPDX-License-Identifier: ISC

