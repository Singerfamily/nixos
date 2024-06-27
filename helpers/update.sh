#!/bin/sh

sudo nix flake update $(dirname -- "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )")