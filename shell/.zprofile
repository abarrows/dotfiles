# Evaluation if this machine is an M1 Mac done in the .m1-fixes.sh file
if [ -r "/opt/homebrew/bin/brew" ]; then
  eval $(/opt/homebrew/bin/brew shellenv)
fi
