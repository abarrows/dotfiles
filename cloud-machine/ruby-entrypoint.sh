# Move general dotfiles to workspace
# cp general/* .

# Move general linting and formatting files to workspace
# cp linting-and-formatting/* .

# Echo where we are and that the setup script is taking place.

# Check ruby version
ruby --version

# Install npm dependencies
yarn install

# Install eslint globally
yarn global add eslint

# Allow our non-root user to access the node modules
sudo chown node node_modules

# Compile the assets
# bundle exec rake assets:precompile

# Update rails dependencies
bundle install

# Start the server
bundle exec rails server -p '3000'

CMD ["$@"]
