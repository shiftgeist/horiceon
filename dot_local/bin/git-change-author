#!/bin/sh

git filter-branch --env-filter '
OLD_EMAIL="FILL HERE"
CORRECT_NAME="FILL HERE"
CORRECT_EMAIL="FILL HERE"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
	export GIT_COMMITTER_NAME="$CORRECT_NAME"
	export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi

if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
	export GIT_AUTHOR_NAME="$CORRECT_NAME"
	export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags

echo "Review the new Git history for errors."
echo "Push the corrected history to Git:"
echo "git push --force --tags origin 'refs/heads/*'"
