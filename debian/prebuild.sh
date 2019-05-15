#!/bin/sh

# Configure tzdata in non-interactive way to avoid stuck on waiting user input
# during dependencies installation.
release=$(lsb_release -c -s)
if [ "${release}" = "bionic" ] || [ "${release}" = "cosmic" ] || \
        [ "${release}" = "disco" ]; then
    # Update packages list to overcome 404 Not found error at
    # downloading tzdata package.
    sudo apt-get update > /dev/null
    echo "Europe/Moscow" | sudo tee /etc/timezone
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
fi
