#!/bin/bash
set -xe

# Move general dotfiles to workspace
# cp general/* .

# Move general linting and formatting files to workspace
# cp linting-and-formatting/* .

# Echo where we are and that the setup script is taking place.

# Check ruby version
echo "RUBY: Your Ruby Version: "
ruby --version

echo "RUBY: Installing ruby gems and dependencies..."
bundle install

echo "YARN: Installing npm packages..."
yarn install --check-files

echo "YARN: Installing npm packages..."
yarn global add eslint

echo "USER: Allow our non-root user to access the node modules"
sudo chown node node_modules

echo "RAILS: Starting server on port 3000"
foreman start

CMD ["$@"]
