#! /bin/sh

uncrustify_config_list='tools/uncrustify.cfg tools/uncrustify-strong.cfg'
sed_script='tools/rewrite.sed'

original_dir='original'
translated_dir='translated'
editor_dir='editor'
compiler_dir='compiler'
editor_name='radiant'
compiler_name='q3map2'

listTree () {
	cat <<-EOF
	aaradiant
	bloodmap
	daemonmap
	darkradiant
	doom3
	etxreal
	gtkradiant
	jack
	jk2radiant
	libradiant
	map220
	map-compiler
	ncustom
	netradiant
	overdose
	qio
	quake3
	ufoai
	urbanterror
	vecxis
	xreal
	EOF
}

printNotice () {
	echo "NOTICE: ${@}" >&2
}

printWarning () {
	echo "WARNING: ${@}" >&2
}

printError () {
	echo "ERROR: ${@}" >&2
	exit 1
}

isTree () {
	tree_name="${1}"
	test_name="$(listTree | grep "^${tree_name}$")"
	[ "x${test_name}" = "x${tree_name}" ]
}

rmDir () {
	if [ -d "${1}" ]
	then
		rm --recursive --verbose --force "${1}"
	fi
}

mkDir () {
	mkdir --parents --verbose "${1}"
}

mvDir () {
	mkdir --parents "${2}"
	rm --recursive --verbose --force "${2}"
	mv --verbose "${1}" "${2}"
}

rsyncDir () {
	source_dir="${1}"
	destination_dir="${2}"
	if [ -d "${source_dir}" ]
	then
		printNotice "rsyncing directories: ${source_dir} ${destination_dir}"
		mkDir "${destination_dir}"
		rsync --archive --checksum --verbose --delete-after "${source_dir}/." "${destination_dir}/."
	else
		printError "directory inexistent: ${source_dir}"
	fi
}

mvFile () {
	mkdir --parents "$(dirname "${2}")"
	mv --verbose "${1}" "${2}"
}

uncrustifyTree () {
	tree_name="${1}"
	if [ -d "${translated_dir}/${tree_name}" ]
	then
		printNotice "translated tree: ${tree_name}"
		for uncrustify_config in ${uncrustify_config_list}
		do
			find "${translated_dir}/${tree_name}" -type f -name '*.c' -o -name '*.h' \
			| uncrustify -c "${uncrustify_config}" --no-backup --mtime -l C -F '/dev/stdin'
			find "${translated_dir}/${tree_name}" -type f -name '*.cpp' \
			| uncrustify -c "${uncrustify_config}" --no-backup --mtime -l CPP -F '/dev/stdin'
		done
	else
		printWarning "tree not translated: ${tree_name}"
	fi
}

astyleTree () {
	tree_name="${1}"
	if [ -d "${translated_dir}/${tree_name}" ]
	then
		printNotice "astyling tree: ${tree_name}"
		(
			cd "${translated_dir}/${tree_name}"
			astyle --recursive --suffix=none --preserve-date --style=bsd --mode=c '*.c' '*.cpp' '*.h'
		)
	else
		printWarning "tree not translated: ${tree_name}"
	fi
}

rewriteString () {
	tree_name="${1}"
	if [ -d "${translated_dir}/${tree_name}" ]
	then
		printNotice "rewriting tree: ${tree_name}"
		find "${translated_dir}/${tree_name}" -type f -name '*.c' -exec sed -f "${sed_script}" -i {} \;
		find "${translated_dir}/${tree_name}" -type f -name '*.h' -exec sed -f "${sed_script}" -i {} \;
		find "${translated_dir}/${tree_name}" -type f -name '*.cpp' -exec sed -f "${sed_script}" -i {} \;
		find "${translated_dir}/${tree_name}" -type f -name '*.hpp' -exec sed -f "${sed_script}" -i {} \;
	else
		printWarning "tree not translated: ${tree_name}"
	fi
}

checkoutSvn () {
	tree_name="${1}"
	if ! [ -d "${original_dir}/${tree_name}" ]
	then
		printNotice "fetching tree: ${tree_name}"
		mkDir "${original_dir}"
		svn checkout "${2}" "${original_dir}/${tree_name}"
	else
		printNotice "tree already fetched: ${tree_name}"
	fi
}

updateSvn () {
	tree_name="${1}"
	if [ -d "${original_dir}/${tree_name}" ]
	then
		printNotice "updating tree: ${tree_name}"
		(
			cd "${original_dir}/${tree_name}"
			svn update
		)
	else
		printWarning "tree not fetched: ${tree_name}"
	fi
}

cloneGit () {
	final_tree_name="${1}"
	if ! [ -d "${original_dir}/${final_tree_name}" ]
	then
		printNotice "fetching tree: ${final_tree_name}"
		mkDir "${original_dir}"
		if [ -z "${3}" ]
		then
			git clone "${2}" "${original_dir}/${final_tree_name}"
		else
			git clone -b "${3}" --single-branch "${2}" "${original_dir}/${final_tree_name}"
		fi
	else
		printNotice "tree already fetched: ${final_tree_name}"
	fi
}

pullGit () {
	final_tree_name="${1}"
	if [ -d "${original_dir}/${final_tree_name}" ]
	then
		printNotice "updating tree: ${final_tree_name}"
		(
			cd "${original_dir}/${final_tree_name}"
			git pull
		)
	else
		printWarning "tree not fetched: ${final_tree_name}"
	fi
}

getJackCompiler () {
	tree_name="${1}"
	jack_dir="${original_dir}/jack/"
	jack_file='jack_latest_linux_x64.run'
	jack_url='http://jack.hlfx.ru/en/download_jackhammer_linux64.html'
	if ! [ -d "${jack_dir}" ]
	then
		printNotice "fetching tree: ${tree_name}"
		mkDir "${jack_dir}"
		(
			cd "${jack_dir}"	
			wget -O "${jack_file}" "${jack_url}"
			known_makeself_version='# This script was generated using Makeself 2.1.5'
			jack_makeself_version="$(head -n 2 "${jack_file}" | tail -n 1)"
			if [ "x${jack_makeself_version}" = "x${known_makeself_version}" ]
			then
				dd if="${jack_file}" bs="$(head -n 401 "${jack_file}" | wc -c | tr -d ' ')" skip=1 \
				| tar --to-stdout --extract --gunzip './quake3/src.zip' \
				| bsdtar -xvf-
			else
				printError "unknown Makeself version for jack file"
			fi
		)
	else
		printNotice "tree already fetched: ${tree_name}"
	fi
}

cppToC() {
	working_dir="${1}"
	if [ -d "${working_dir}" ]
	then
		printNotice "renaming cpp to c from directory: ${working_dir}"
		(
			find "${working_dir}" -maxdepth 1 -exec rename --force --verbose 's/\.cpp$/.c/' {} \;
		)
	else
		printError "directory inexistent: ${working_dir}"
	fi
}

lowerCaseDir () {
	working_dir="${1}"
	if [ -d "${working_dir}" ]
	then
		printNotice "lowering case file names from directory: ${working_dir}"
		find "${working_dir}" -maxdepth 1 -exec rename --force --verbose 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
	else
		printError "directory inexistent: ${working_dir}"
	fi
}

cleanTree () {
	tree_name="${1}"
	if isTree "${tree_name}"
	then
		printNotice "cleaning tree: ${tree_name}"
		rmDir "${translated_dir}/${tree_name}"
	else
			printError "unknown tree: ${tree_name}"
	fi
}

purgeTree () {
	tree_name="${1}"
	if isTree "${tree_name}"
	then
		printNotice "purging tree: ${tree_name}"
		rmDir "${original_dir}/${tree_name}"
	else
		printError "unknown tree: ${tree_name}"
	fi
}

fetchTree () {
	tree_name="${1}"
	case "${tree_name}" in
		'aaradiant')
			checkoutSvn "${tree_name}" 'https://github.com/ECToo/aa3rdparty/trunk/tools/aaradiant'
		;;
		'bloodmap')
			cloneGit "${tree_name}" 'https://github.com/paulvortex/BloodMap.git'
		;;
		'daemonmap')
			cloneGit "${tree_name}" 'https://github.com/Unvanquished/daemonmap.git'
		;;
		'darkradiant')
			cloneGit "${tree_name}" 'https://github.com/codereader/DarkRadiant.git'
		;;
		'doom3')
			cloneGit "${tree_name}" 'https://github.com/id-Software/DOOM-3.git'
		;;
		'etxreal')
			cloneGit "${tree_name}" 'http://git.code.sf.net/p/xreal/ET-XreaL'
		;;
		'gtkradiant')
			cloneGit "${tree_name}" 'https://github.com/TTimo/GtkRadiant.git'
		;;
		'jack')
			getJackCompiler "${tree_name}"
		;;
		'jk2radiant')
			checkoutSvn "${tree_name}" 'https://github.com/jedis/jedioutcast/trunk/utils'
		;;
		'libradiant')
			cloneGit "${tree_name}" "https://github.com/KILLTUBE/libradiant.git"
		;;
		'map220')
			cloneGit "${tree_name}" 'https://github.com/FreeSlave/GtkRadiant.git' 'map220'
		;;
		'map-compiler')
			cloneGit "${tree_name}" 'https://github.com/isRyven/map-compiler.git'
		;;
		'ncustom')
			cloneGit "${tree_name}" "https://github.com/Garux/netradiant-custom.git"
		;;
		'netradiant')
			cloneGit "${tree_name}" 'https://gitlab.com/xonotic/netradiant.git'
		;;
		'overdose')
			checkoutSvn "${tree_name}" 'https://svn.code.sf.net/p/odblur/code/code/OverDose Tools'
		;;
		'qio')
			checkoutSvn "${tree_name}" 'https://svn.code.sf.net/p/qio/code/trunk/code/tools'
		;;
		'quake3')
			cloneGit "${tree_name}" 'https://github.com/id-Software/Quake-III-Arena.git'
		;;
		'ufoai')
			checkoutSvn "${tree_name}" 'https://github.com/ufoai/ufoai/trunk/src/tools'
		;;
		'urbanterror')
			fetchTree 'gtkradiant'
		;;
		'vecxis')
			mkDir "${original_dir}/${tree_name}"
			cloneGit "${tree_name}/vradiant" 'http://projects.gamebuf.com/Vecxis/vradiant.git'
			cloneGit "${tree_name}/vmapc" 'http://projects.gamebuf.com/Vecxis/vmapc.git'
		;;
		'xreal')
			checkoutSvn "${tree_name}" 'https://github.com/raynorpat/xreal/trunk/code/tools'
		;;
		*)
			printError "unknown tree: ${tree_name}"
		;;
	esac
}

transTree () {
	tree_name="${1}"
	match='true'
	case "${tree_name}" in
		'aaradiant')
			rsyncDir "${original_dir}/${tree_name}/include" "${translated_dir}/${tree_name}/${editor_dir}/include"
			rsyncDir "${original_dir}/${tree_name}/libs" "${translated_dir}/${tree_name}/${editor_dir}/libs"
			rsyncDir "${original_dir}/${tree_name}/plugins" "${translated_dir}/${tree_name}/${editor_dir}/plugins"
			rsyncDir "${original_dir}/${tree_name}/radiant" "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
			;;
		'bloodmap')
			rsyncDir "${original_dir}/${tree_name}/src" "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
			mvDir "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}/common" "${translated_dir}/${tree_name}/${compiler_dir}/common"
			mvDir "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}/games" "${translated_dir}/${tree_name}/${compiler_dir}/games"
			mvDir "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}/libs" "${translated_dir}/${tree_name}/${editor_dir}/libs"
		;;
		'daemonmap')
			rsyncDir "${original_dir}/${tree_name}/src/include" "${translated_dir}/${tree_name}/${editor_dir}/include"
			rsyncDir "${original_dir}/${tree_name}/src/libs" "${translated_dir}/${tree_name}/${editor_dir}/libs"
			rsyncDir "${original_dir}/${tree_name}/src/tools/common" "${translated_dir}/${tree_name}/${compiler_dir}/common"
			rsyncDir "${original_dir}/${tree_name}/src/tools/owmap" "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
		;;
		'darkradiant')
			rsyncDir "${original_dir}/${tree_name}/include" "${translated_dir}/${tree_name}/${editor_dir}/include"
			rsyncDir "${original_dir}/${tree_name}/libs" "${translated_dir}/${tree_name}/${editor_dir}/libs"
			rsyncDir "${original_dir}/${tree_name}/plugins" "${translated_dir}/${tree_name}/${editor_dir}/plugins"
			rsyncDir "${original_dir}/${tree_name}/radiant" "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
		;;
		'doom3')
			rsyncDir "${original_dir}/${tree_name}/neo/tools/radiant" "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
			lowerCaseDir "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
		;;
		'etxreal')
			rsyncDir "${original_dir}/${tree_name}/src/tools/etxradiant/include" "${translated_dir}/${tree_name}/${editor_dir}/include"
			rsyncDir "${original_dir}/${tree_name}/src/tools/etxradiant/libs" "${translated_dir}/${tree_name}/${editor_dir}/libs"
			rsyncDir "${original_dir}/${tree_name}/src/tools/etxradiant/plugins" "${translated_dir}/${tree_name}/${editor_dir}/plugins"
			rsyncDir "${original_dir}/${tree_name}/src/tools/etxradiant/radiant" "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
			rsyncDir "${original_dir}/${tree_name}/src/tools/common" "${translated_dir}/${tree_name}/${compiler_dir}/common"
			rsyncDir "${original_dir}/${tree_name}/src/tools/etxmap" "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
		;;
		'gtkradiant'|'ncustom'|'netradiant'|'libradiant')
			rsyncDir "${original_dir}/${tree_name}/contrib" "${translated_dir}/${tree_name}/${editor_dir}/contrib"
			rsyncDir "${original_dir}/${tree_name}/include" "${translated_dir}/${tree_name}/${editor_dir}/include"
			rsyncDir "${original_dir}/${tree_name}/libs" "${translated_dir}/${tree_name}/${editor_dir}/libs"
			rsyncDir "${original_dir}/${tree_name}/plugins" "${translated_dir}/${tree_name}/${editor_dir}/plugins"
			rsyncDir "${original_dir}/${tree_name}/radiant" "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
			rsyncDir "${original_dir}/${tree_name}/tools/quake3/common" "${translated_dir}/${tree_name}/${compiler_dir}/common"
			rsyncDir "${original_dir}/${tree_name}/tools/quake3/q3map2" "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
		;;
		'jack')
			rsyncDir "${original_dir}/${tree_name}/q3map2/src" "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
			mvDir "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}/common" \
				"${translated_dir}/${tree_name}/${compiler_dir}/common"
		;;
		'jk2radiant')
			rsyncDir "${original_dir}/${tree_name}/common" "${translated_dir}/${tree_name}/${editor_dir}/common"
			rsyncDir "${original_dir}/${tree_name}/Libs" "${translated_dir}/${tree_name}/${editor_dir}/libs"
			rsyncDir "${original_dir}/${tree_name}/Radiant" "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
		;;
		'map220')
			rsyncDir "${original_dir}/${tree_name}/tools/quake3/common" "${translated_dir}/${tree_name}/${compiler_dir}/common"
			rsyncDir "${original_dir}/${tree_name}/tools/quake3/q3map2" "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
		;;
		'map-compiler')
			rsyncDir "${original_dir}/${tree_name}/code/" "${translated_dir}/${tree_name}/${compiler_dir}"
			mvDir "${translated_dir}/${tree_name}/${compiler_dir}/compiler" "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
		;;
		'overdose')
			rsyncDir "${original_dir}/${tree_name}/ODRadiant" "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
			rsyncDir "${original_dir}/${tree_name}/ODMap" "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
			cppToC "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
		;;
		'qio')
			rsyncDir "${original_dir}/${tree_name}/q3radiant" "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
			lowerCaseDir "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
		;;
		'quake3')
			rsyncDir "${original_dir}/${tree_name}/q3radiant" "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
			rsyncDir "${original_dir}/${tree_name}/q3map" "${translated_dir}/${tree_name}/${compiler_dir}/q3map"
			lowerCaseDir "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
		;;
		'ufoai')
			rsyncDir "${original_dir}/${tree_name}/radiant" "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
			rsyncDir "${original_dir}/${tree_name}/ufo2map" "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
			cppToC "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
			mvDir "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}/common" "${translated_dir}/${tree_name}/${compiler_dir}/common"
		;;
		'urbanterror')
			rsyncDir "${original_dir}/gtkradiant/tools/urt/tools/quake3/q3map2" "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
		;;
		'vecxis')
			rsyncDir "${original_dir}/${tree_name}/vradiant" "${translated_dir}/${tree_name}/${editor_dir}"
			rsyncDir "${original_dir}/${tree_name}/vmapc" "${translated_dir}/${tree_name}/${compiler_dir}"
		;;
		'xreal')
			rsyncDir "${original_dir}/${tree_name}/gtkradiant/include" "${translated_dir}/${tree_name}/${editor_dir}/include"
			rsyncDir "${original_dir}/${tree_name}/gtkradiant/libs" "${translated_dir}/${tree_name}/${editor_dir}/libs"
			rsyncDir "${original_dir}/${tree_name}/gtkradiant/plugins" "${translated_dir}/${tree_name}/${editor_dir}/plugins"
			rsyncDir "${original_dir}/${tree_name}/gtkradiant/radiant" "${translated_dir}/${tree_name}/${editor_dir}/${editor_name}"
			rsyncDir "${original_dir}/${tree_name}/common" "${translated_dir}/${tree_name}/${compiler_dir}/common"
			rsyncDir "${original_dir}/${tree_name}/xmap2" "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}"
			mvFile "${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}/xmap2.h" \
				"${translated_dir}/${tree_name}/${compiler_dir}/${compiler_name}/${compiler_name}.h"
		;;
		*)
			match='false'
			printError "unknown tree: ${tree_name}"
		;;
	esac

	if "${match}"
	then
		uncrustifyTree "${tree_name}"
		rewriteString "${tree_name}"
	fi
}

updateTree () {
	tree_name="${1}"
	case "${tree_name}" in
		'aaradiant'|'jk2radiant'|'overdose'|'ufoai'|'xreal')
			updateSvn "${tree_name}"
		;;
		'bloodmap'|'daemonmap'|'darkradiant'|'etxreal'|'gtkradiant'|'ncustom'|'netradiant'|'map220'|'quake3'|'doom3')
			pullGit "${tree_name}"
		;;
		'jack')
			printNotice "not updatable tree: ${tree_name}"
		;;
		'urbanterror')
			updateTree 'gtkradiant'
		;;
		'vecxis')
			pullGit "${tree_name}/vradiant"
			pullGit "${tree_name}/vmapc"
		;;
		*)
			printError "unknown tree: ${tree_name}"
		;;
	esac
}

printHelp () {
	tab="$(printf '\t')"
	cat <<-EOF
	Usage: ${0} [arg] [tree]

	args:
	${tab}-h, --help
	${tab}${tab}print this help
	${tab}-c, --clear
	${tab}${tab}delete translated tree
	${tab}-p, --purge
	${tab}${tab}delete original and translated tree
	${tab}-f, --fetch
	${tab}${tab}fetch original tree
	${tab}-u, --update
	${tab}${tab}update original tree
	${tab}-t, --translate
	${tab}${tab}translate from original tree
	${tab}${tab}and do some conversion to reduce diff noise

	trees:
	${tab}all
	$(listTree | sed -e 's/^/\t/')

	EOF

	exit
}

if [ "x${1}" = 'x' ]
then
	printHelp
fi

action_clean=false
action_fetch=false
action_purge=false
action_trans=false
action_update=false
tree_list=""

for var_arg in ${@}
do
	case ${var_arg} in
		'-c'|'--clean')
			action_clean=true
		;;
		'-f'|'--fetch')
			action_fetch=true
		;;
		'-h'|'--help')
			printHelp
		;;
		'-p'|'--purge')
			action_purge=true
		;;
		'-t'|'--translate')
			action_trans=true
		;;
		'-u'|'--update')
			action_update=true
		;;
		-*|--*)
		printError "unknown action: ${var_arg}"
		;;
		'all')
		tree_list="${tree_list} $(listTree)"
		;;
		*)
		tree_list="${tree_list} ${var_arg}"
		;;
	esac
done

tree_list="$(echo "${tree_list}" | tr ' ' '\n' | sort -u)"

# do actions in this order

if ${action_clean}
then
	for tree_name in ${tree_list}
	do
		cleanTree "${tree_name}"
	done
fi

if ${action_purge}
then
	for tree_name in ${tree_list}
	do
		cleanTree "${tree_name}"
		purgeTree "${tree_name}"
	done
fi

if ${action_fetch}
then
	for tree_name in ${tree_list}
	do
		fetchTree "${tree_name}"
	done
fi

if ${action_update}
then
	for tree_name in ${tree_list}
	do
		fetchTree "${tree_name}"
		updateTree "${tree_name}"
	done
fi

if ${action_trans}
then
	for tree_name in ${tree_list}
	do
		fetchTree "${tree_name}"
		transTree "${tree_name}"
	done
fi

#EOF
