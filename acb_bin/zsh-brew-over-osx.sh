# https://rick.cogley.info/post/use-homebrew-zsh-instead-of-the-osx-default/
zsh --version \
which zsh \
dscl . -read /Users/$USER UserShell \

# Actually do the business and make brew installed zsh the preferred shell
brew install zsh \
ls -la /usr/local/bin/zs* \
# lrwxr-xr-x  1 rcogley  wheel  27 May 16 10:54 /usr/local/bin/zsh@ -> ../Cellar/zsh/5.0.7/bin/zsh
#   lrwxr-xr-x  1 rcogley  wheel  33 May 16 10:54 /usr/local/bin/zsh-5.0.7@ ->
#   ../Cellar/zsh/5.0.7/bin/zsh-5.0.7
brew list zsh \
brew info zsh \
sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh \
which zsh \
# /usr/local/bin/zsh
zsh --version \
# Should be the same as first check.
dscl . -read /Users/$USER UserShell \
# UserShell: /usr/local/bin/zsh
echo $SHELL
# Should be: /usr/local/bin/zsh

# To set brew zsh in iTerm 2: Preferences, Profiles, General, Command.

# Considerations
# There are a couple of considerations to keep in mind any time you upgrade OS X.

# First, your shell might get reset, so check it to be sure.

# Secondly, OS X El Capitan (v 10.11) has a new security system called “System Integrity Protection”, which is set up to be stricter with the security of /usr/local, among other things. Since this is where brew keeps its files, you’ll likely need to reset security on it by running the following command:
sudo chown -R $(whoami):admin /usr/local
