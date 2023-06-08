#!/bin/bash
#
# An example hook script to verify what is about to be committed.
# Called by "git commit" with no arguments. The hook should
# exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.
#
# To enable this hook, rename this file to "pre-commit".

# Redirect output to stderr.
exec 1>&2


# Prevent large large
FILE_SIZE_LIMIT_KB=$1
CURRENT_DIR="$(pwd)"
HAS_ERROR=""
COUNTER=0

# before git commit, check non git-lfs tracked files to limit size
files=$(git diff --cached --name-only | sort | uniq)
while read -r file; do
	if [ "$file" = "" ]; then
		continue
	fi
	file_path=$CURRENT_DIR/$file
	file_size=$(ls -l "$file_path" | awk '{print $5}')
	file_size_kb=$((file_size / 1024))
	if [ "$file_size_kb" -ge "$FILE_SIZE_LIMIT_KB" ]; then
		echo "${file} has size ${file_size_kb}KB, over commit limit ${FILE_SIZE_LIMIT_KB}KB."
		HAS_ERROR="YES"
		((COUNTER++))
	fi
done <<< "$files"

# exit with error if any non-lfs tracked files are over file size limit
if [ "$HAS_ERROR" != "" ]; then
	echo "$COUNTER files are larger than permitted, please fix them before commit" >&2
	exit 1
fi

exit 0