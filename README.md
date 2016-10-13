Radiant Compare
===============

This is a tool to help diffing multiple forks of the radiant editor and q3map2 compiler. It downloads multiple source trees, rename some stuff and apply an `uncrustify` profile on them to reduce diff noise. Original trees take places in `original` directory while translated trees take places in the `translated` directory.

For example you can import GtkRadiant and NetRadiant source trees this way:

```sh
./do.sh --translate gtkradiant netradiant
```

This way you can compare them with your favorite diffing tool:

```sh
meld translated/gtkradiant/editor/radiant translated/netradiant/editor/radiant
```

These are editor trees supported:
- AARadiant from AlienArena (ECToo)
- GtkRadiant from Id Software (TTimo)
- NetRadiant from Xonotic
- ODRadiant from Overdose (Odblur)
- QioRadiant from Qio (Vodin)
- DarkRadiant from CodeReader

These are compiler trees supported:
- Q3map2 from GtkRadiant (TTimo)
- Q3map2 from NetRadiant (Xonotic)
- Q3map2 from UrbanTerror (TTimo)
- Q3map2 from J.A.C.K.
- Xmap2 from XreaL (RaynorPat)
- ODMap from Overdose (Odblur)
- Daemonmap from Unvanquished

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
