#!/bin/bash
# Sync extra data that not handled by hg

if [ $# -eq "0" ] || [ -z $1 ]; then
  echo "Usage: ./run_sync.sh {push|pull} [options to rsync]"
  exit 0
fi

# relative path of the directory that you want to backup
DIR_REL='sparse_net_gc/GCinfo/'  # always add the tailing slash


DIR_LOCAL="`hg root`/$DIR_REL"

DIR_REMOTE=`hg paths default`
if [[ $? -ne "0" ]]; then
  echo "Failed to acquire sync url"
  exit 1
fi
# get path suitable for rsync
DIR_REMOTE=`echo $DIR_REMOTE | sed 's=.*://==' | sed 's=/=:$HOME/='`
DIR_REMOTE="$DIR_REMOTE/$DIR_REL"

rs='rsync -ah --progress'
case $1 in
  pull)
    shift
    $rs $* $DIR_REMOTE $DIR_LOCAL
    ;;
  push)
    shift
    $rs $* $DIR_LOCAL $DIR_REMOTE
    ;;
esac

