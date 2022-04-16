#!/bin/bash

# First check if bundler is installed
if [ ! -x "$(command bundle -v)" ]; then
  echo "The Bundler gem is NOT already installed."
  gem install bundler
  gem update --system
else
  echo "Bundler IS already installed."
fi
