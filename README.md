ttupload.sh is a small script for creating torrents and auto-uploading it to TT.


 Requirements:
  * /dev/hands and /dev/head
  * curl v7.20.0+
  * mktorrent v1.0+
  * running rtorrent v0.8.0+ with watch dir setuped


TODO:
  * auto-recognition of release type
  * parse response from tracker if torrent was really uploaded or failed
  * correctly handle releases without .nfo files
  * moar fool protections


Changes:
  2010-07-23 13:30 - initial release


Internal:

 1) check release and stuff
 2) parse .nfo and dirname
 3) mktorrent
 4) ???
 5) curl it!
 6) mv .torrent to rtorrent watch dir


* thanks to m0viefreak for helping me out with some things. \o/
