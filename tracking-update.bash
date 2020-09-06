#!/bin/bash

set -e -o pipefail

: ${GITHUB_TOKEN:?" should be set"}
: ${DEBUG:-""}


GITHUB_API_URL="https://api.github.com"
GITHUB_URL="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com"
SOURCE_REPO="rust-lang/rust"
SINK_REPO="watawuwu/docker-rust"
CUR_DIR=$(cd $(dirname $0); pwd)
WORK_DIR="${CUR_DIR}/_tmp"

cleanup() {
  echo "Clean up"
  rm -rf "${WORK_DIR}"
}
trap cleanup EXIT
trap "exit 1" INT ERR TERM

verlt() {
  arg1="$1"
  arg2="$2"

  [[ "$arg1" = "$arg2" ]] && return 1

  old="$(echo -e "${arg1}\n${arg2}" | sort -V | head -n1)"

  [[ "$arg1" = "$old" ]]
}


source_all_tags=$(curl -sS -H "Authorization: token $GITHUB_TOKEN" $GITHUB_API_URL/repos/$SOURCE_REPO/tags)
source_tags=$(echo "$source_all_tags" | jq -r '.[].name' | perl -nle 'print if /^(\d+).(\d+).(\d+)$/' | sort -V )

sink_all_tags=$(curl -sS -H "Authorization: token $GITHUB_TOKEN" $GITHUB_API_URL/repos/$SINK_REPO/tags)
sink_latest_tag=$(echo "$sink_all_tags" | jq -r '.[].name' | perl -nle 'print if /^(\d+).(\d+).(\d+)$/' | sort -rV | head -n1)

added_tag=""
while read tag; do
  if verlt "$sink_latest_tag" "$tag" ;then
    added_tag="$tag"
  fi
done<<<"$source_tags"

[[ -z "$added_tag" ]] && exit

git clone --depth=1 -b master "${GITHUB_URL}/${SINK_REPO}.git" "${WORK_DIR}"
git config --global user.name "github-actions"
git config --global user.email "watawuwu+ghbot@3bi.tech"

cd "${WORK_DIR}"
perl -pi -e "s/ENV RUST_VERSION=.+/ENV RUST_VERSION=${added_tag}/g" Dockerfile
git add Dockerfile
git commit -m "feat: bump up rust to ${added_tag}"

git tag "$added_tag"
${DEBUG} git push origin master
${DEBUG} git push origin "$added_tag"
