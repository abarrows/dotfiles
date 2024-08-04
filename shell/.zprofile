# Evaluation if this machine is an M1 Mac done in the .m1-mysql-fixes.sh file
if [ -r "/opt/homebrew/bin/brew" ]; then
  eval $(/opt/homebrew/bin/brew shellenv)
fi
if [[ $- == *i* ]] && [ -t 0 ]; then
  echo "This is an interactive shell"
else
  echo "This is not an interactive shell"
fi
