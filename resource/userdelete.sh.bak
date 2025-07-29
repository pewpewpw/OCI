#!/bin/bash
#2017.03.03
#this is for 12.04, need to check 16.04 works?

sudo su << EOF

#delete unused user and make system user to not use ssh
deluser games
deluser news
deluser irc

usermod -s nologin daemon
usermod -s nologin bin
usermod -s nologin sys
usermod -s nologin sync
usermod -s nologin man
usermod -s nologin lp
usermod -s nologin mail
usermod -s nologin uucp
usermod -s nologin proxy
usermod -s nologin www-data
usermod -s nologin backup
usermod -s nologin list
usermod -s nologin gnats
usermod -s nologin nobody
usermod -s nologin libuuid

#remove unnesecery dircetory
rm -rf /usr/games
rm -rf /usr/local/games
rm /usr/share/doc/netcat-openbsd/examples/irc

EOF
