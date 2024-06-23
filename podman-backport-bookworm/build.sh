#!/bin/bash

set -euxo pipefail

cd "$(dirname ${BASH_SOURCE[0]})"

export DEBIAN_FRONTEND=noninteractive
TAG=v5.1.1
DEBIAN_REV=40cce732502c55e598b68a2b8f4288e6db221a55

mkdir -p /etc/apt/sources.list.d
cat <<EOF > /etc/apt/sources.list.d/src.list
deb-src http://deb.debian.org/debian testing main
deb http://deb.debian.org/debian bookworm-backports main
EOF
apt-get update -qy
apt-get install -qy -t bookworm-backports golang
apt-get install -qy packaging-dev debian-keyring devscripts equivs curl

git clone --depth=1 -b $TAG https://github.com/containers/podman.git podman
curl "https://salsa.debian.org/debian/libpod/-/archive/${DEBIAN_REV}/libpod-${DEBIAN_REV}.tar.gz?path=debian" | tar -C podman --strip-components=1 -zxv
cp -r debian podman

cd podman
git add -f .
git -c user.name=root -c user.email='root@localhost' commit -m 'import debian'
git tag -f $TAG
mk-build-deps --install --remove --tool 'apt-get -qy -o Debug::pkgProblemResolver=yes --no-install-recommends'
git clean -xfd
dpkg-buildpackage --build=binary --unsigned-changes
