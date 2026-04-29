#!/usr/bin/env bash
# Create a new aspect from the template.
# Usage: new-aspect <domain> <name>
# Example: new-aspect services my-feature
#
# Domain must be an existing directory under modules/aspects/.
# The new file will be modules/aspects/<domain>/<name>.nix.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
TEMPLATE="$REPO_ROOT/templates/ASPECT_TEMPLATE.nix"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "Usage: $0 <domain> <name>"
    echo "  domain  - subdirectory under modules/aspects/, possibly nested"
    echo "            (e.g. apps, dev, hardware, shell, ai,"
    echo "            services/system, services/network, services/user,"
    echo "            desktop/plasma)"
    echo "  name    - aspect name, must match the filename (e.g. my-feature)"
    exit 1
}

[ $# -eq 2 ] || usage

DOMAIN="$1"
NAME="$2"
DEST_DIR="$REPO_ROOT/modules/aspects/$DOMAIN"
DEST_FILE="$DEST_DIR/$NAME.nix"

if [ ! -d "$DEST_DIR" ]; then
    echo -e "${RED}Error: domain directory does not exist: $DEST_DIR${NC}"
    echo "Valid domains: $(ls "$REPO_ROOT/modules/aspects/" | tr '\n' ' ')"
    exit 1
fi

if [ -f "$DEST_FILE" ]; then
    echo -e "${RED}Error: file already exists: $DEST_FILE${NC}"
    exit 1
fi

sed "s/my-feature/$NAME/g" "$TEMPLATE" > "$DEST_FILE"

echo -e "${GREEN}Created: $DEST_FILE${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit the aspect:  \$EDITOR $DEST_FILE"
echo "  2. Track it in git:  git add $DEST_FILE"
echo "  3. Validate:         nix flake check --no-build"
echo "  4. Include it in a host or user via den.aspects.$NAME"
