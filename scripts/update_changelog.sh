#!/bin/bash
# Description: This script generates markdown files for each release of kubevirt in repository
# Generated markdown files should be stored under _posts/ for website rendering

set +x

TARGET='build'
BOT="$1"

mkdir -p build/artifacts || continue
[[ -e build/kubevirt ]] || git clone https://github.com/kubevirt/kubevirt.git build/kubevirt/
git -C build/kubevirt checkout master
git -C build/kubevirt pull --tags

function releases() {
git -C build/kubevirt tag | sort -rV | while read TAG ;
do
  [[ "$TAG" =~ [0-9].0$ ]] || continue ;
  # Skip following releases as there's a manual article for them
  [[ "$TAG" == "v0.1.0" ]] && continue ;
  [[ "$TAG" == "v0.2.0" ]] && continue ;
  echo "$TAG" ;
done
}

function features_for() {
  echo -e  ""
  git -C build/kubevirt show $1 | grep Date: | head -n1 | sed "s/Date:\s\+/Released on: /"
  echo -e  ""
  git -C build/kubevirt show $1 | sed -n "/changes$/,/Contributors/ p" | egrep "^- " ;
}

function gen_changelog() {
  {
  echo "Generating changelog from Git Tags..."
  for REL in $(releases);
  do
    FILENAME="changelog-$REL.markdown"
    cat <<EOF >  $FILENAME
---
layout: post
author: kubebot
description: This article provides information about Kube Virt release $REL changes
navbar_active: Blogs
datefixme:
category: releases
comments: true
title: Kube Virt $REL
pub-date: July 23
pub-year: 2018
---

EOF

    (
    echo -e "\n## $REL" ;
    features_for $REL
    )>> "$FILENAME"
    daterelease=$(cat "$FILENAME"| grep "Released on" |cut -d ":" -f 2-)
    sed -i "s#^datefixme: #date: $daterelease#g" "$FILENAME"
    newdate=$(echo $daterelease|tr " " "\n"|grep -v "+"|tr "\n" " ")
    year=$(date --date="$newdate" '+%Y')
    month=$(date --date="$newdate" '+%m')
    monthname=$(LANG=C date --date="$newdate" '+%B')
    day=$(date --date="$newdate" '+%d')
    NEWFILENAME="build/artifacts/$year-$month-$day-$FILENAME"
    mv $FILENAME $NEWFILENAME
    sed -i "s#^pub-date:.*#pub-date: $monthname#g" "$NEWFILENAME"
    sed -i "s#^pub-year:.*#pub-year: $year#g" "$NEWFILENAME"
    echo "File ${NEWFILENAME} created"
  done
  }
}

function get_git_field() {
    # Get Git Username from K8s secret
    # The secret is mounted on 

    GIT_CRED_PATH=/etc/git-creds/.git-credentials
    field=$1

    if [[ -f ${GIT_CRED_PATH} ]]; then
        RESULT="$(grep ${field} /etc/git-creds/.git-credentials | cut -f2 -d=)"
    else
        echo "The Git credentials file does not exists plz create the secret on the correct namespace"
        exit 1
    fi
}

function git_configure() {
    # This function will prepare your Git Config for pushing events
    # I've use this method instead of git-credentials because, for whatever reason the images Git version
    # is not the correct one to work with credentials properly, even creating the secret
    USERNAME="${1:-kubevirt-bot}"
    TOKEN="$2"
    REPO="$(git config --get remote.origin.url | cut -f2 -d@)"

    [[ -z ${USERNAME} ]] && (get_git_field "username" && USERNAME=${RESULT})
    [[ -z ${TOKEN} ]] && (get_git_field "password" && TOKEN=${RESULT})
    ln -fs /etc/gitconfig/git-config ${HOME}/.gitconfig
    ls -lah ${HOME}

    git remote set-url origin https://${USERNAME}:${TOKEN}@${REPO}
}

gen_changelog

for file in build/artifacts/*.markdown; do
    [ -f _posts/$(basename $file) ] || mv $file _posts/
done

git add _posts/
git_configure "${BOT}"
git commit -m "Release autobot 🚗---->🤖"
git push --set-upstream origin master
