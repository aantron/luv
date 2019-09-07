set -e
set -x

if [ "$TRAVIS_EVENT_TYPE" == cron ]
then
    rm -rf ~/.opam
    rm -rf ./_opam
    rm -rf ./_cache
fi

VERSION=2.0.5

case "$TRAVIS_OS_NAME" in
    linux) OS=linux;;
      osx) OS=macos;;
        *) echo Unsupported system $TRAVIS_OS_NAME; exit 1;;
esac

FILENAME=opam-$VERSION-x86_64-$OS

wget https://github.com/ocaml/opam/releases/download/$VERSION/$FILENAME
sudo mv $FILENAME /usr/local/bin/opam
sudo chmod a+x /usr/local/bin/opam

opam init -y --bare --disable-sandboxing --disable-shell-hook
if [ ! -d _opam/bin ]
then
    rm -rf _opam
    opam switch create . $COMPILER $REPOSITORIES --no-install
fi
