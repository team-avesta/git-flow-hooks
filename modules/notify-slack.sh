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

SLACK_MESSAGE="$COMMAND/$CURRENT_VERSION $ACTION"

if [[ $ACTION == "finished" ]]; then
  VERSION_CURRENT=$(__get_current_version)

  VERSION_PREFIX=$(git config --get gitflow.prefix.versiontag)
  VERSION="$VERSION_PREFIX$VERSION_CURRENT"
  echo $VERSION

  PREV_VERSION=$(git describe --abbrev=0 --tags $(git rev-list --tags --max-count=2) | tail -1)

  CHANGES=$(git log --no-merges --pretty=format:" * %s (%an)" "$VERSION"..."$PREV_VERSION")
  echo $CHANGES
  SLACK_MESSAGE="$SLACK_MESSAGE\n\nChanges:\n$CHANGES"
fi


if [[ $ACTION == "started" ]]; then
  echo "$COMMAND/$CURRENT_VERSION"

  PREV_VERSION=$(git describe --abbrev=0 --tags $(git rev-list --tags --max-count=1))

  CHANGES=$(git log --no-merges --pretty=format:" * %s (%an)" "$COMMAND/$CURRENT_VERSION"..."$PREV_VERSION")
  echo $CHANGES
  SLACK_MESSAGE="$SLACK_MESSAGE\n\nChanges:\n$CHANGES"
fi

echo $SLACK_MESSAGE

curl -s \
  -d "payload={\"text\":\"$SLACK_MESSAGE\"}" \
  $SLACK_WEBHOOK_URL \
  > /dev/null
