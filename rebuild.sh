#!/bin/sh
# Apply the configuration. Callable from anywhere.
set -e
DIR=$(cd "$(dirname "$0")" && pwd)
exec home-manager switch --flake "$DIR#simon"
