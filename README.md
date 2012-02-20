INSTALL
=======

    git clone git://github.com/panshadow/git-tickets.git
    cd git-tickets
    make install
    cd YOUR_GIT_REPO
    git tickets init


USE
===

    cd YOUR_GIT_REPO
    # set custom pattern
    git config --file=.git/config tickets.pattern 'REGEXP_PATTERN'
    # install hook
    git tickets init
