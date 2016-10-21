#!/usr/bin/env bash
set -e
set -o errexit
set -o errtrace

fetch() {
  local url="$1"
  local file="$2"
  if hash wget 2> /dev/null ; then
    wget -c -O "$file" "$url"
  else
    curl -O "$file" "$url"
  fi
}

discover_goos() {
  case $(uname -s) in
    "Darwin")
      echo -n darwin
      ;;
    "Linux")
      echo -n linux
      ;;
    "FreeBSD")
      echo -n freebsd
      ;;
    *)
      echo "error: Only darwin, linux, and freebsd are supported at the moment." 1>&2
      echo "error: Pull requests are welcome!" 1>&2
      echo "error: https://github.com/siadat/installgo" 1>&2
      exit 1
  esac
}

discover_goarch() {
  case $(uname -m) in
    "amd64")
      uname -m
      ;;
    "x86_64")
      echo -n "amd64"
      ;;
    *)
      echo "error: $(uname -m) is not supported at the moment." 1>&2
      echo "error: Pull requests are welcome!" 1>&2
      echo "error: https://github.com/siadat/installgo" 1>&2
      exit 1
      ;;
  esac
}

main() {
  local goos=$(discover_goos)
  local goarch=$(discover_goarch)
  local version=$1
  local url="https://storage.googleapis.com/golang/go$version.$goos-$goarch.tar.gz"
  local gopath='$HOME/go'
  local profile=~/.bashrc
  local dir=~/go$version

  if [ -d $dir ]; then
    echo "error: $dir already exists" 1>&2
    exit 1
  fi

  # TODO(sina): support other shells
  if [ ! -f $profile ]; then
    echo "error: Only bash is supported at the moment." 1>&2
    echo "error: Send a pull request to support your shells!" 1>&2
    echo "error: https://github.com/siadat/installgo" 1>&2
    exit 1
  fi

  fetch "$url" "/tmp/$(basename "$url")"
  tmpdir=$(mktemp -d)
  tar -C $tmpdir -xzf "/tmp/$(basename "$url")"
  mv $tmpdir/go $dir
  echo "Installed on $dir"

  cat >> $profile << EndOfMsg
export GOROOT=$dir
export GOPATH=$gopath
export PATH=\$PATH:$dir/bin:\$GOPATH/bin
EndOfMsg
  echo "Added paths to $profile"
}

if [ "$1" = "" ]; then
  echo "Usage: $0 1.7.1"
  exit 1
fi
main $1
echo "Close and reopen your terminal and run 'go' to test your installation!"
