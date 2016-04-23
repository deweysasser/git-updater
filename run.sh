#!/bin/bash

# Intentionally DO NOT set -e -- we want to keep running if at all possible
set -u

SANDBOX=${SANDBOX:-$HOME/sandbox}
LOOP=${LOOP:-false}
SIGNED=${SIGNED:-false}
SLEEP=${SLEEP:-60}
DIR=${DIR:-.}
BRANCH=${BRANCH:-master}

# A place to put command line argument which will be run *after* updating
declare -a COMMAND
COMMAND=('')
KEYS="${KEYS:-}"

update-sandbox() {
    git -C "$SANDBOX" pull
}

ensure-ssh-key() {
    if [ ! -f ~/.ssh/id_dsa ] ; then
	ssh-keygen -t dsa -N "" -f ~/.ssh/id_dsa
    fi
}


clone-sandbox() {
    git clone -b "$BRANCH" "$SOURCE" "$SANDBOX"
}

check-signature() {
    if [ $SIGNED == false ] ; then
	return 0
    fi
	
    tagname=$(eval git -C "$SANDBOX" describe --abbrev=0 --tags origin/${BRANCH} | grep release | head -n 1)
    echo "Checking tag name $tagname"
    if [ -z "$tagname" ] ; then
	echo "No tag found"
	return 1
    fi

    git -C "$SANDBOX" tag -v $tagname && git checkout $tagname
}

copy-files() {
    rsync -rav --delete --exclude '.git' "$SANDBOX/${DIR}/" "$TARGET/"
}

runonce() {
    date
    startingCommit=$(gitcommit)
    if [ -d "$SANDBOX/.git" ] ; then
	update-sandbox
    else
	if clone-sandbox ; then
	    echo "Cloned initial files from $SOURCE"
	else
	    echo "Failed to clone from $SOURCE.  Is the SSH key correctly configured?"
	    cat ~/.ssh/id_dsa.pub
	    return
	fi
    fi

    if ! check-signature; then
	return
    fi

    postupdateCommit=$(gitcommit)

    if [ "$startingCommit" == "$postupdateCommit" -a -d "$TARGET" ] ; then
	return
    fi

    copy-files
    runcommand
}

gitcommit() {
	if [ ! -d "$SANDBOX/.git" ] ; then
	    echo ""
	else
	    git -C "$SANDBOX" rev-parse HEAD
	fi
}

runcommand() {
    if [ -n "${COMMAND[*]}" ] ; then
	(
	    cd "$TARGET"
	    # Ignore any errors from here
	    eval "${COMMAND[@]}" || true
	)
    fi
}

import-gpg-keys() {
    for f in $KEYS/*.asc $HOME/key.asc; do
	if [ -f $f ] ; then
	    gpg --import $f
	fi
    done
}

loop() {
    runonce
    while sleep $SLEEP; do
	runonce
    done
}

usage() {

    cat <<EOF
usage:  docker run deweysasser/git-updater [options] [commands]
   or 
        docker run -d deweysasser/git-updater  [options] -loop [commands]
   or 
        docker run -it deweysasser/git-updater  -shell [args...]

options are:

-help -- this text
-shell -- invoke a bash shell with the remaining arguments
-loop -- loop continously
-source SOURCE -- set the source dir to SOURCE.  Currently ${SOURCE:-empty}${SOURCE:+'$SOURCE'}
-signed -- if set, copy files from the latest signed tag.  Currently '$SIGNED'.
-target TARGET -- set the target dir to TARGET.  Currently '${TARGET:-}'.
-keys KEYS -- set the keys dir to KEYS.  Currently '$KEYS'.
-sleep SLEEP -- number of seconds to sleep between polls.  Currently '$SLEEP'.
-standbox SANDBOX -- the location of the git sandbox used to poll
-branch BRANCH -- branch of the git repository to clone and/or examine for signed tags
-dir DIR -- directory within the repositor to copy to the TARGET

You may also specify each of SOURCE, TARGET and KEYS as environment
variables as well as set the value of SIGNED to 'false' (to avoid
signatures) or anything else (to check signatures)

You may optionally specificy a COMMAND to run after the update (and
signature check, if any) is successful.

EOF
}

while [ -n "$*" ] ; do
    case $1 in
	-help) usage; exit 0;;
	-shell) shift; exec bash "$@" ;; 
	-loop) LOOP=true;;
	-signed) SIGNED=true; loop;;
	-source) SOURCE="$2"; shift;;
	-target) TARGET="$2"; shift;;
	-sleep) SLEEP="$2"; shift;;
	-sandbox) SANDBOX="$2"; shift;;
	-branch) BRANCH="$2"; shift;;
	-dir) DIR="$2"; shift;;
	-keys) KEYS="$2"; shift;;
	--) shift; COMMAND+=("$@"); break;;
	-*) usage; exit 1;;
	*) COMMAND+=("$1");;
    esac
    shift
done

if [ -z "${SOURCE:-}" ] ; then
    echo "environment variable SOURCE must be a valid git URL"
    exit 1
fi

if [ -z "${TARGET:-}" ] ; then
    echo "environment variable TARGET must be a valid directory"
    exit 1
fi

mkdir -p "$SANDBOX" $(dirname "$TARGET")

import-gpg-keys
ensure-ssh-key

cd "$SANDBOX"

if $LOOP ; then
    loop
else
    runonce
fi


	