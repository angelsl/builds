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
  EDITOR=true EMAIL="root@localhost" dch --bpo ""
  dpkg-buildpackage --build=binary --unsigned-changes
  cd ..
  dpkg -i *.deb || true
  apt-get -qy install -f || true
  popd
}

mkdir -p /etc/apt/sources.list.d
cat <<EOF > /etc/apt/sources.list.d/src.list
deb-src http://deb.debian.org/debian testing main
EOF
apt-get update -qy
apt-get install -qy packaging-dev debian-keyring devscripts equivs

dopkg golang-github-containers-storage
dopkg golang-github-container-orchestrated-devices-container-device-interface
dopkg golang-github-containers-buildah-dev

dopkg golang-github-checkpoint-restore-go-criu
dopkg golang-github-checkpoint-restore-checkpointctl

dopkg libpod
