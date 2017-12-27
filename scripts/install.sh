##
# Install MiCloud server config.
##

# Failure is not an option.
set -e

# Get git root (assumes 1 dir above this script).
ROOTDIR="$(cd "$(dirname "$0")/.."; pwd -P)"

##
# Colours are nice.
##
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Disable SELinux. TODO: Figure out proper systemd perms.
echo "Disabling SELinux (NOTE: If this script fails, make sure you run 'sudo setenforce 1'!)"
setenforce 0

# Install our systemd units.
echo "Installing systemd units"

# Systemd doesn't like enabling unit templates anymore...
ln -sf "$ROOTDIR"/systemd/alert-on-failure@.service /etc/systemd/system/alert-on-failure@.service

# Install everything else normally.
shopt -s extglob
for item in "$ROOTDIR"/systemd/!(alert-on-failure@.service); do
  # Systemd has started to output nonsense warnings about missing [Install]
  # sections (even for the ones that do have one) so we need to shut it up.
  echo "Quietly enabling $item"
  systemctl enable "$item" --force > /dev/null 2>&1
done
systemctl daemon-reload

# Start/restart systemd timers.
for item in "$ROOTDIR"/systemd/*.timer; do
  # NOTE: Re-enabling an existing timer will kill it so it must be restarted.
  systemctl stop $(basename "$item")
  systemctl start $(basename "$item")
done

# Re-enable SELinux.
echo "Re-enabling SELinux"
setenforce 1

# Create envfile with path.
echo "Installing MiCloud config"
if [ ! -f "$ROOTDIR/micloud-server.env" ]; then
  echo
  echo -e "${RED}Failed to install micloud config!${NC}"
  echo -e "${RED}Please create $ROOTDIR/micloud-server.env from $ROOTDIR/micloud-server.env.example.${NC}"
  echo
  exit 1
fi
cp "$ROOTDIR/micloud-server.env" /etc/micloud-server.env
echo "MICLOUD_PATH=\"$ROOTDIR\"" >> /etc/micloud-server.env

# Report success.
echo
echo -e "${GREEN}Install ran successfully!${NC}"
echo
