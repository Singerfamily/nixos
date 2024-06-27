#!/bin/sh

# This will harden the security of these dotfiles, preventing
# unpriveleged users from editing system-level (root configuration)
# files maliciously

# Run this inside of ~/.dotfiles (or whatever directory you installed
# the dotfiles to)

# Run this as root!

# BTW, this assumes your user account has a PID/GID of 1000

# After running this, the command `nix flake update` will require root

if [ "$#" = 1 ]; then
    SCRIPT_DIR=$1;
else
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    FLAKE_DIR=
fi
pushd $SCRIPT_DIR &> /dev/null;
chown -R 0:0 $(dirname $SCRIPT_DIR)/.;
chown 0:0 $SCRIPT_DIR/harden.sh;
chown 0:0 $SCRIPT_DIR/update.sh;
popd &> /dev/null;