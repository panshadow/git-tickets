ABOUT
-----

It's commit-msg hook with installator. Support custom commit message pattern.


INSTALL
-------

    git clone git://github.com/panshadow/git-tickets.git
    cd git-tickets
    make install

UPGRADE
_______

    cd path/git-tickets
    git pull
    make install


USAGE
-----

    cd YOUR_GIT_REPO
    # install hook
    git tickets init
    #custom pattern
    git tickets pattern 'REGEXP_PATTERN'
