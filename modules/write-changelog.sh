#!/usr/bin/env bash

USE_CHANGELOG=$(__get_use_changelog)
if [ "$CHANGELOG_ENABLED" = true  ]; then
  VERSION_CURRENT=$(__get_current_version)
  CHANGELOG_FILE=$(__get_changelog_file)
  CHANGE=$($HOOKS_DIR/modules/gitlog-to-changelog.sh
  $VERSION_CURRENT $VERSION "$CHANGELOG_FILE")
fi
