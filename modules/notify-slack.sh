#!/usr/bin/env bash

if [[ $NOTIFY_TO_SLACK == false ]]; then
    exit 0
fi

function __print_usage {
    echo "Usage: $(basename $0) [<command>] [<version>] [<action>]"
    echo "    <command>:     release/hotfix"
    echo "    <version>:     version"
    echo "    <action>:      started/finished"
    exit 1
}

if [ $# -gt 3 ]; then
    __print_usage
fi

COMMAND=$1
CURRENT_VERSION=$2
ACTION=$3

USER=`git config user.name`
SLACK_MESSAGE="\`$COMMAND/$CURRENT_VERSION\` $ACTION by $USER"

if [[ $ACTION == "finished" ]]; then
  VERSION_CURRENT=$(__get_current_version)

  VERSION_PREFIX=$(git config --get gitflow.prefix.versiontag)
  VERSION="$VERSION_PREFIX$VERSION_CURRENT"
  PREV_VERSION=$(git describe --abbrev=0 --tags $(git rev-list --tags --max-count=2) | $VERSION_SORT -V | head -1)

  CHANGES=$(git log --no-merges --pretty=format:"%s (%an)\n" "$VERSION"..."$PREV_VERSION")
  SLACK_MESSAGE="$SLACK_MESSAGE\n\nChanges:\n$CHANGES"
fi


if [[ $ACTION == "started" ]]; then
  PREV_VERSION=$(git describe --abbrev=0 --tags $(git rev-list --tags --max-count=1))

  CHANGES=$(git log --no-merges --pretty=format:"%s (%an)\n" "$COMMAND/$CURRENT_VERSION"..."$PREV_VERSION")
  SLACK_MESSAGE="$SLACK_MESSAGE\n\nChanges:\n$CHANGES"
fi

SLACK_MESSAGE=`echo $SLACK_MESSAGE | sed "s/\"/'/g"`

curl -X POST -s --data-urlencode "payload={\"text\":\"$SLACK_MESSAGE\"}" $SLACK_WEBHOOK_URL
