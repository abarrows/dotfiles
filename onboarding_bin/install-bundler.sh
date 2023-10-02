#!/bin/bash

# First check if bundler is installed
if [ ! -x "$(command bundle -v)" ]; then
  echo "The Bundler gem is NOT already installed."
  rbenv install "$(rbenv install -l | grep -v - | tail -1)"
else
  echo "Bundler IS already installed."
fi
