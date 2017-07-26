#! /bin/sh

# generate a README.md file with up-to-date built-in help.

test -f 'README.md' && rm 'README.md'
exec 1<&-
exec 1<>'README.md'

cat <<\EOF
Radiant Compare
===============

This is a tool to help diffing multiple forks of the radiant editor and q3map2 compiler. It downloads multiple source trees, rename some stuff and apply an `uncrustify` profile on them to reduce diff noise. Original trees take places in `original` directory while translated trees take places in the `translated` directory.

Source trees are fetched as repositories so it's easy to compare revisions. To save time, some git trees are fetched using svn though the GitHub svn bridge when the radiant stuff is just a part of an heavier repository.

Examples
--------

You can import GtkRadiant and NetRadiant source trees this way:

```sh
./do --translate gtkradiant netradiant
```

This way you can compare them with your favorite diffing tool:

```sh
meld translated/gtkradiant translated/netradiant
```

Same between DarkRadiant and ETXRadiant:

```sh
./do --translate darkradiant etxreal
meld translated/darkradiant translated/etxreal
```

Suported trees
--------------

These are editor trees supported:
- [AARadiant](https://github.com/ECToo/aa3rdparty) from [Alien Arena](http://red.planetarena.org) (ECToo) _- GtkRadiant fork_
- [DarkRadiant](http://darkradiant.sourceforge.net) from [The Dark Mod](http://www.thedarkmod.com) (CodeReader) _- GtkRadiant fork_
- [ETXRadiant](https://sourceforge.net/p/xreal/ET-XreaL) from [ET-XreaL](http://www.moddb.com/mods/etxreal) (XreaL) _- DarkRadiant fork_
- [GtkRadiant](http://icculus.org/gtkradiant) from id Software (TTimo)
- [NetRadiant](https://gitlab.com/xonotic/netradiant) from [Xonotic](http://xonotic.org/) _- GtkRadiant fork_
- [ODRadiant](https://sourceforge.net/projects/odblur) from [Overdose](http://www.moddb.com/games/overdose) (Odblur) _- GtkRadiant fork_
- [QioRadiant](https://sourceforge.net/projects/qio) from Qio (Vodin) _- Q3Radiant fork_
- [UFORadiant](https://github.com/ufoai/ufoai/) from [UFO:AI](http://ufoai.org) _- GtkRadiant fork with DarkRadiant additions_

These are compiler trees supported (all Q3map2 forks):
- [BloodMap](https://github.com/paulvortex/BloodMap) from [RazorWind](http://razorwind.ru/) (paulvortex)
- [Daemonmap](https://github.com/Unvanquished/daemonmap) from [Unvanquished](https://unvanquished.net)
- ETXMap from ET-XreaL (XreaL)
- ODMap from Overdose (Odblur)
- Q3map2 from GtkRadiant (TTimo)
- Q3map2 from [J.A.C.K.](http://jack.hlfx.ru/en/) (XaeroX)
- Q3map2 from NetRadiant (Xonotic)
- Q3map2 from UrbanTerror (TTimo)
- Ufo2map from UFO:AI
- [Map220](https://github.com/FreeSlave/GtkRadiant/tree/map220) (J.A.C.K. changes from XaeroX ported by FreeSlave to GtkRadiant tree)
- Xmap2 from [XreaL](https://github.com/raynorpat/xreal/) (RaynorPat)

Help
----

```
EOF

./do --help

cat <<\EOF
```

Dependencies
------------

You will need `git`, `svn`, `rsync`, `uncrustify` and `sed` to process the common repositories, but also `dd`, `gzip`, `tar` and `bsdtar` (yes, both) for the cryptic q3map2 code extraction from _J.A.C.K._ installer.

Warning
-------

No warranty is given, use this at your own risk.

Author
------

Thomas Debesse <dev@illwieckz.net>

Copyright
---------

This script is distributed under the highly permissive and laconic [ISC License](COPYING.md).

The shipped `uncrustify.cfg` file was imported from the GtkRadiant source tree and can be subject to another license (BSD or GPL).
EOF

#EOF
