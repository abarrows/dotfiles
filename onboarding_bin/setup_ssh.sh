#!/bin/bash

# NOTE: Decide if you want to clear out all your ssh keys.  If so, uncomment out
# the next line.
# rm -rf ~/.ssh/

# Step 1.  Create an initial SSH key value pair
ssh-keygen -t ed25519 -C abarrows@amuniversal.com

# Step 2. Press enter on the file location.

# Step 3. Enter a passphrase

# Instantiate the ssh-agent
# Step 4. Setup ssh agent
eval "$(ssh-agent -s)"

# Step 5. Check if ssh agent is already created.
~/.ssh/config

# Step 6. Create file if it is not there.
touch ~/.ssh/config

# Step 7. Add the following to that file
# NOTE: Only add UseKeychain yes if using a passphrase
# Host *
#   AddKeysToAgent yes
#   IdentityFile ~/.ssh/id_ed25519
#   UseKeychain yes

# Step 8. Add the ssh key.
ssh-add ~/.ssh/id_ed25519

# Step 9. Enter your passphrase
# Identity should be added.
# Copy the contents of your public key for step 10.
cat ~/.ssh/id_ed25519.pub

# Step 10. Navigate to [github.com](https://github.com/settings/ssh/new) and
# add create new SSH key title (make sure it is meaningful) and paste in your
# ssh key that is in your clipboard. Create key when finished.

# Step 11. Try out this by cloning into a repo using the "Code" dropdown button
# within a github repo.
