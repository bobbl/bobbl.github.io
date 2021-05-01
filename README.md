Build github pages locally
--------------------------

Dependencies

    sudo apt install ruby bundler jekyll

In the `USER.github.io` directory

    bundle install

Render the site to <http://localhost:4000>

    bundle exec jekyll serve



Update jekyll in the case of security vulnerabilities
-----------------------------------------------------

    bundle update github-pages