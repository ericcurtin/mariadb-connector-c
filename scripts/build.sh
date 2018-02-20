#!/bin/bash

d_exe() {
  local user=$1
  local cmd=$3

  docker exec -u "$user" "$name" /bin/bash -c "$cmd"
}

d_run() {
  local img=$1
  local cmd=$2

  local user=$(id -un)
  local gid=$(id -g)
  local group=$(id -gn)

  docker rm -f "$name" || true
  docker run --privileged -d -v /tmp:/tmp -v "/home/$user:/home/$user" -h\
         "$name" --name "$name" "$img" init
  d_exe "root"\
    "groupadd -g $gid $group && useradd -M -s /bin/bash -g $gid -u $UID $user"
  d_exe "$UID" "cd $PWD && $cmd"
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
    mv mariadb-connector-c-3.0.3-*.tar.gz\
    ../packages/mariadb-connector-c-3.0.3-$name.tar.gz"

  d_run "$doc" "$cmd"
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

