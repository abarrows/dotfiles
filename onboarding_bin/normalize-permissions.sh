#!/bin/bash

# Set permissions back to user.
sudo chown -R $(whoami) $(brew --prefix)/*
