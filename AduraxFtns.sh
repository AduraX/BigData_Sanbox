#!/usr/bin/env bash
# cd vcpHdpEcoCluster & Give execute permission to the script:  chmod +x runEc2.sh & Execute by: ./runEc2.sh
if test "`echo -e`" = "-e" ; then ECHO=echo ; else ECHO="echo -e" ; fi

contains() { # Para: aList anItem | Return: [0： match, 1: failed] | Run: contains "A B C D" g

    [[ $1 =~ (^|[[:space:]])$2($|[[:space:]]) ]]  #exit(0) || exit(1)
    echo $?
}


inputValidation() { # para: optionParaList inputPara inputName | Run: inputValidation "A B C D" g  Letters
local Indx=0
while [ $Indx -lt 3 ]
do
  Indx=$(( Indx+1 ))
  if [ $Indx -eq 1 ]; then
    Inputs=${2^^}
    result=$(contains " \"_- $1 -_\" " $Inputs)
  else
    $ECHO "\nThe option for \"$3\" must be one of these [$1]. \nType one of the options and press [ENTER]:"
    read Inputs && Inputs=${Inputs^^}
    result=$(contains " \"_- $1 -_\" " $Inputs)
  fi

  if [ $result = "0" ]; then
    $ECHO "\n$3: $Inputs accepted.\n"
    break
  else
    if [ $Indx -eq 3 ]; then
      $ECHO "*** Invalid input! Exiting after the third attempt...\n"
      exit
    else
      $ECHO "*** Invalid input try again."
    fi
  fi
done
}


timeDiff() { # para: InitialDateTime FinalDateTime
  local diffSec=$(( $2 - $1 ))
  local day=$(($diffSec/86400))
  local hour=$(($(($diffSec - $diffSec/86400*86400))/3600))
  local min=$(($(($diffSec - $diffSec/86400*86400))%3600/60))
  local ret=""
  if [ $day -gt 0 ]; then
    ret=$(echo ${day}d ${hour}h:${min}m:$(($(($diffSec - $diffSec/86400*86400))%60))s)
  elif [ $hour -gt 0 ]; then
    ret=$(echo ${hour}h:${min}m:$(($(($diffSec - $diffSec/86400*86400))%60))s)
  else
    ret=$(echo ${min}m:$(($(($diffSec - $diffSec/86400*86400))%60))s)
  fi

  echo The elapsed time between initial time[$(date --date @$1 +"%a, %d-%b-%Y %H:%M:%S")] and final time[$(date --date @$2 +"%a, %d-%b-%Y %H:%M:%S")]: $ret
}
