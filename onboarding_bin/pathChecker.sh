#!/bin/bash

# COMMAND: cat pathChecker.sh
path2chk="${@?usage:${0##*/} /path/to/check}"
if ! [[ -d "${path2chk}" ]] ; then
   echo "no directory access to ${path2chk}"
   echo "checking all elements anyway"
fi

echo "${path2chk}"\
| sed 's/\//\n/g' \
| while read pathElem ; do
    testPath="${testPath+${testPath}/}${pathElem}"
    #dbg echo "ls -ld \"$testPath\""
    ls -ld "$testPath"
done


chmod +x pathChecker.sh
pathChecker.sh '/Volumes/Flash Player/Install Adobe Flash Player.app/Contents/MacOS/Adobe Flash Player Install Manager'
