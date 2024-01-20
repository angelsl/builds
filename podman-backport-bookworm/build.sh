#!/bin/bash

set -euxo pipefail

cd "$(dirname ${BASH_SOURCE[0]})"

export DEBIAN_FRONTEND=noninteractive

dopkg() {
  mkdir "$1"
  pushd "$1"
  apt-get source "$1"/testing
  cd "$1"-*/
  mk-build-deps --install --remove --tool 'apt-get -qy -o Debug::pkgProblemResolver=yes --no-install-recommends'
  yes | dch --bpo ""
  dpkg-buildpackage --build=binary --unsigned-changes
  cd ..
  dpkg -i *.deb || true
  apt-get -qy install -f || true
  popd
}

echo 'deb-src http://deb.debian.org/debian/ testing main' >> /etc/apt/sources.list
apt-get update -qy
apt-get install -qy packaging-dev debian-keyring devscripts equivs

dopkg golang-github-checkpoint-restore-go-criu
dopkg golang-github-checkpoint-restore-checkpointctl
dopkg libpod
