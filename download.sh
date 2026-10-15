#!/usr/bin/env bash
set -euo pipefail

if (( $# > 1 )); then
  printf 'Usage: %s [dataset-parent-directory]\n' "$0" >&2
  exit 2
fi
repo=acmer2017/MCviz-datasets
tag=static-v2026.10.15
asset=k-partite-graph-static.tar.gz
expected_sha256=3042755b10546942673901b7835819484e4c172e64dbd52bf03b2e17069d83a2
mkdir -p -- "${1:-.}"
parent=$(cd -- "${1:-.}" && pwd -P)
target=$parent/k-partite-graph
if [[ -e "$target" || -L "$target" ]]; then
  printf 'Refusing to overwrite existing dataset: %s\n' "$target" >&2
  exit 1
fi

cache=$parent/.mcviz-datasets-cache/$tag
mkdir -p -- "$cache"
archive=$cache/$asset
check_archive() {
  (cd -- "$cache" && printf '%s  %s\n' "$expected_sha256" "$1" | sha256sum --check --status)
}
if [[ ! -f "$archive" ]] || ! check_archive "$asset"; then
  if [[ ! -f "$archive.part" ]] || ! check_archive "$asset.part"; then
    curl --fail --location --retry 5 --retry-delay 2 --connect-timeout 20 \
      --continue-at - --output "$archive.part" \
      "https://github.com/$repo/releases/download/$tag/$asset"
  fi
  if ! check_archive "$asset.part"; then
    printf 'Archive checksum failed. Remove this cached partial file and retry: %s\n' "$archive.part" >&2
    exit 1
  fi
  mv -f -- "$archive.part" "$archive"
fi

temporary=$(mktemp -d "$parent/.mcviz-datasets-unpack.XXXXXXXX")
trap 'rm -rf -- "$temporary"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
tar --extract --gzip --file "$archive" --directory "$temporary" --no-same-owner
(cd -- "$temporary" && sha256sum --check k-partite-graph/SHA256SUMS) >&2
mv --no-clobber --no-target-directory -- "$temporary/k-partite-graph" "$target"
if [[ -e "$temporary/k-partite-graph" ]]; then
  printf 'Dataset destination appeared during download; refusing to overwrite: %s\n' "$target" >&2
  exit 1
fi
printf '%s\n' "$target"
