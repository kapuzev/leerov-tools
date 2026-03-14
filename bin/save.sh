#!/bin/bash

if [ -z "$1" ]; then
    echo "Ошибка: Укажите название коммита."
    exit 1
fi

commit_message="$*"

git checkout -b develop 2>/dev/null || git checkout develop

# Lj,fdkztv dct bpvty`yyst afqks, yt njkmrj .c b .h
git add -A

git commit -m "$commit_message"
git push --set-upstream origin develop
