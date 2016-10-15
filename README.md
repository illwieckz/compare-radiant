Radiant Compare
===============

This is a tool to help diffing multiple forks of the radiant editor and q3map2 compiler. It downloads multiple source trees, rename some stuff and apply an `uncrustify` profile on them to reduce diff noise. Original trees take places in `original` directory while translated trees take places in the `translated` directory.

Source trees are fetched as repositories so it's easy to compare revisions. To save time, some git trees are fetched using svn though the GitHub svn bridge when the radiant stuff is just a part of an heavier repository.

Examples
--------

You can import GtkRadiant and NetRadiant source trees this way:

```sh
./do.sh --translate gtkradiant netradiant
```

This way you can compare them with your favorite diffing tool:

```sh
meld translated/gtkradiant translated/netradiant
```

Same between DarkRadiant and ETXRadiant:

```sh
./do.sh --translate darkradiant etxreal
meld translated/darkradiant translated/etxreal
```

Suported trees
--------------

These are editor trees supported:
- [AARadiant](https://github.com/ECToo/aa3rdparty) from [Alien Arena](http://red.planetarena.org) (ECToo) _- GtkRadiant fork_
- [ETXRadiant](https://sourceforge.net/p/xreal/ET-XreaL) from [ET-XreaL](http://www.moddb.com/mods/etxreal) (XreaL) _- DarkRadiant fork_
- [GtkRadiant](http://icculus.org/gtkradiant) from id Software (TTimo)
- [NetRadiant](https://gitlab.com/xonotic/netradiant) from [Xonotic](http://xonotic.org/) - _GtkRadiant fork_
- [ODRadiant](https://sourceforge.net/projects/odblur) from [Overdose](http://www.moddb.com/games/overdose) (Odblur) _- GtkRadiant fork_
- [QioRadiant](https://sourceforge.net/projects/qio) from Qio (Vodin) _- Q3Radiant fork_
- [DarkRadiant](http://darkradiant.sourceforge.net) from [The Dark Mod](http://www.thedarkmod.com) (CodeReader) _- GtkRadiant fork_

These are compiler trees supported (all Q3map2 forks):
- ETXMap from ET-XreaL (XreaL)
- Q3map2 from GtkRadiant (TTimo)
- Q3map2 from NetRadiant (Xonotic)
- Q3map2 from UrbanTerror (TTimo)
- Q3map2 from [J.A.C.K.](http://jack.hlfx.ru/en/)
- Xmap2 from [XreaL](https://github.com/raynorpat/xreal/) (RaynorPat)
- ODMap from Overdose (Odblur)
- [Daemonmap](https://github.com/Unvanquished/daemonmap) from [Unvanquished](https://unvanquished.net)

Help
----

```
Usage: ./do.sh [arg] [tree]

args:
	-h, --help
		print this help
	-c, --clear
		delete translated tree
	-p, --purge
		delete original and translated tree
	-f, --fetch
		fetch original tree
	-u, --update
		update original tree
	-t, --translate
		translate from original tree
		and do some conversion to reduce diff noise

trees:
	all
	aaradiant
	daemonmap
	darkradiant
	etxreal
	jack
	gtkradiant
	netradiant
	overdose
	qio
	ufoai
	urbanterror
	xreal

```

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
