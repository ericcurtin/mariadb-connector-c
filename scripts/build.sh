#!/bin/bash

d_exe() {
  local user=$1
  local name=$2
  local cmd=$3

  docker exec -u "$user" "$name" /bin/bash -c "$cmd"
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
  d_exe "$UID" "$name" "cd $PWD && $cmd"
  docker rm -f "$name" || true
}

d_compile() {
  local cc=$1
  local cxx=$2
  local pre=$3

  if [ -z "$pre" ]; then
    pre="true"
  fi

  local cmd="$pre && export CC=$cc && export CXX=$cxx && rm -rf bin &&\
    mkdir bin && cd bin && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. &&\
    make -j5 VERBOSE=1 && make package &&\
    mv mariadb-connector-c-3.0.3-linux-x86_64.tar.gz ../packages/"

  d_run "$name" "$doc" "$cmd"
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

