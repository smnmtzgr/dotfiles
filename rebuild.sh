#!/bin/sh
# Wendet die Konfiguration an. Aufrufbar von ueberall.
set -e
DIR=$(cd "$(dirname "$0")" && pwd)
exec home-manager switch --flake "$DIR#simon"
