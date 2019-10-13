#!/bin/bash

#
# ttupload.sh is a small script for auto-uploading releases to tt
#
# requirements:
#  * /dev/hands and /dev/head
#  * curl v7.20.0+
#  * mktorrent v1.0+
#  * running rtorrent v0.8.0+ with watch dir setuped
#
# todo:
#  * auto-recognition of release type
#  * parse response from tracker if torrent was really uploaded or failed
#  * correctly handle releases without .nfo files
#  * moar fool protections
#
# changes:
#
#  2010-07-23 13:30 - initial release
#
# internal:
#
# 1) check release and stuff
# 2) parse .nfo and dirname
# 3) mktorrent
# 4) ???
# 5) curl it!
# 6) mv .torrent to rtorrent watch dir
#

#
# thanks to m0viefreak for helping me out with some things. \o/
#

VERSION=0.1

#
# [CONFIG SECTION]
#

# your tt user id and session hash
# !!! THIS IS NOT YOUR REAL TT USERNAME AND PASSWORD !!!
# it's just cookie. you can find it in your browser's cookie cache
# for trancetraffic.com domain
TTUID=12345
TTHASH=HASH
# your passkey
TTPASSKEY=PASSKEY
# upload as self or anonymous
TTUPAS="self" # self or anon
# rtorrent watch dir
TORRENTDIR=~/.rtorrent/watch


# announce url
ANNOUNCEURL="http://tracker.trancetraffic.com:80/announce.php?passkey=$TTPASSKEY"

# w00t - default for tt
POSTURL=http://www.trancetraffic.com/takeupload.php
REFURL=http://www.trancetraffic.com/upload.php



echo ttupload.sh v$VERSION by sud3n@tt

if [ $# -lt 2 ]
then
    cat << EOF

Usage: ttupload.sh [-a] <type> <dir>

Types: 35 - Albums - Dance       28 - Albums - Goa/Psy      29 - Albums - Hardcore
       26 - Albums - Hardstyle   38 - Albums - House        39 - Albums - Other
       27 - Albums - Techno      24 - Albums - Trance

       36 - Singles - Dance      25 - Singles - Goa/Psy     32 - Singles - Hardcore
       22 - Singles - Hardstyle  21 - Singles - House       23 - Singles - Other
       20 - Singles - Techno     19 - Singles - Trance

       37 - Livesets - Goa/Psy   17 - Livesets - Hardstyle  16 - Livesets - House
       18 - Livesets - Other     14 - Livesets - Techno     12 - Livesets - Trance

       10 - Amateur              40 - Ambient/Chill/Lo-Fi   42 - Beat/Breaks
       41 - Drum & Bass/Jungle   5  - DVD/Video/Clips       43 - Electronic

       45 - Music Plugins/Apps/Misc
       6  - TranceTraffic Packs

       0  - Try to auto-detect it from .nfo or dirname          (DISABLED)

      -a  -  Upload torrent as anonymous                        (OPTIONAL)
EOF
    exit 1
elif [ $# -eq 3 ]
then
    if [ $1 != "-a" ]
    then
        echo error: invalid command line argument
        exit 1
    fi
    TTUPAS="anon"
    UPTYPE=$2
    DIR=$3
elif [ $# -eq 2 ]
then
  UPTYPE=$1
  DIR=$2
fi

if [ ! -d $DIR ]
then
    echo error: unable to find directory $DIR
    exit 1
fi

RELNAME=`basename $DIR`

NFOFILE=`find $DIR -name *.nfo`
if [ -z $NFOFILE ]
then
    echo error: no .nfo file found in $DIR
    exit 1
fi

echo Using $NFOFILE ...

if [ $UPTYPE == 0 ]
then
    echo error: auto type recognition is broken
    exit 1
fi



echo Making torrent for $RELNAME ...
mktorrent -p -v -a $ANNOUNCEURL $DIR
RELNAMETOR=$RELNAME.torrent
if [ ! -f $RELNAMETOR ]
then
    echo mktorrent: failed to create torrent file
    exit 1
fi

echo -n Uploading torrent to tracker ...
curl -s -f -H "Expect:" --referer $REFURL --cookie "uid=$TTUID; pass=$TTHASH" -F MAX_FILE_SIZE=1048576 -F "file=@$RELNAMETOR;type=application/x-bittorrent" -F name=$RELNAME -F "nfo=@$NFOFILE;type=application/x-nfo" -F "url=http://www.trancetraffic.com/" -F "descr=`cat $NFOFILE`" -F strip=1 -F type=$UPTYPE -F upas=$TTUPAS $POSTURL > /dev/null

echo Moving torrent file to $TORRENTDIR ...
if [ -f $RELNAMETOR ]
then
    mv $RELNAMETOR $TORRENTDIR
fi
