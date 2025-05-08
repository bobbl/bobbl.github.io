Install jekyll from gem
-----------------------

Add to `.bashrc`

    # Install Ruby Gems to ~/.local/share/gems
    export GEM_HOME="$HOME/.local/gems"
    export PATH="$PATH:$HOME/.local/gems/bin"


Install via gem

    sudo apt-get install ruby-full build-essential zlib1g-dev
    gem install jekyll bundler



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