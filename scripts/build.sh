#!/bin/bash

d_exe() {
  local user=$1
  local name=$2
  local cmd=$3

  docker exec -u "$user" "$name" /bin/bash -c "cd $PWD && $cmd"
}

d_run() {
  local name=$1
  local img=$2
  local cmd=$3

  local user=$(id -un)
  local gid=$(id -g)
  local group=$(id -gn)

  docker rm -f "$name" || true
  docker run --privileged -d -v /tmp:/tmp -v "/home/$user:/home/$user" -h\
         "$name" --name "$name" "$img" init
  d_exe "root" "$name"\
    "groupadd -g $gid $group && useradd -M -s /bin/bash -g $gid -u $UID $user"
  d_exe "$UID" "$name" "$cmd"
}

d_compile() {
  local cc=$1
  local cxx=$2
  local pre=$3

  local platform=$(printf "$name" | sed "s/mariadb-connector-c-//g")

  if [ -z "$pre" ]; then
    pre="true"
  fi

  if [ "$platform" != "i386el6" ]; then
    local build_type="-DCMAKE_BUILD_TYPE=Release"
  fi

  local cmd="$pre && export CC=$cc && export CXX=$cxx && mkdir bin && cd bin &&\
    cmake $build_type -DCMAKE_INSTALL_PREFIX:PATH=/usr .. &&\
    make -j5 VERBOSE=1"

  d_run "$name" "$doc" "$cmd"
  d_exe "root" "$name" "cd bin && export CC=$cc && export CXX=$cxx &&\
    make package && mv mariadb-connector-c-3.0.3-*.tar.gz\
    ../packages/mariadb-connector-c-3.0.3-$platform.tar.gz && cd .. &&\
    rm -rf bin"
  docker rm -f "$name" || true
}

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR/.."

mkdir -p packages

for doc in $(dockerfiles/docker.sh list); do
  name=$(printf "$doc" | sed "s#curtine/##" | sed "s/:/-/")

  d_compile "gcc" "g++"
done

