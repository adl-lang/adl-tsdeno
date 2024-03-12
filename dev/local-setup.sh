#!/bin/bash
# Configures tooling, downloading as required

if [ -n "$ZSH_VERSION" ]; then
  # zsh is the default shell on osx
  reporoot="$( cd -- "${0:a:h}/.." >/dev/null 2>&1 ; pwd -P )"
else
   # assume Bash
  reporoot="$( cd -- "$(dirname "$BASH_SOURCE")/.." >/dev/null 2>&1 ; pwd -P )"
fi

localdir=$reporoot/.local
localbin=$localdir/bin

pathadd() {
    if [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1${PATH:+":$PATH"}"
    fi
}

pathadd $localbin

if [ "`uname`" = "Darwin" ]; then
  platform=osx
  arch=x86_64-apple-darwin
  cachedir=$HOME/Library/Caches/hxtools
elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
  platform=linux
  arch=x86_64-unknown-linux-gnu
  cachedir=$HOME/.cache/hxtools
else
  echo "ERROR: Unable to download tooling for platform"
  return 1
fi

#  Fetch deno if not already downloaded
denoversion=1.41.2
release=https://github.com/denoland/deno/releases/download/v$denoversion/deno-$arch.zip
download=$cachedir/deno-v$denoversion-$arch.zip
if [ ! -f "$download" ]; then
  echo "fetching $release ..."
  mkdir -p $(dirname $download)
  (curl --silent --location $release --output $download || (echo "download failed"; exit 1))
fi

#  Install deno
if [ ! -f "$localdir/bin/deno" ]; then
  echo "unzipping $download ..."
  mkdir -p $localbin
  (cd $localbin; unzip -q -o $download)
fi

# Now use a deno script to install all other local tooling
deno task local-setup
source $localdir/bin/local-env.sh

