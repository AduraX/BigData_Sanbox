#! /bin/bash
if test "`echo -e`" = "-e" ; then ECHO=echo ; else ECHO="echo -e" ; fi

# ./exec.sh parameters.lt

declare -a arrPar=()
i=0; j=0 #Starting reading fro line 5 | parItem = 1st Item, OtherItem=2nd item after splitting with '#'
while IFS="#" read -r parItem OtherItem ; do
  if [ $i -gt 5 ]; then
    arrPar[j]=`echo $parItem | sed 's/ *$//g'`
    echo -e "Line $i [$j]: $parItem => $OtherItem \t\tArr[$i] = ${arrPar[$j]}"
    j=$((j+1))
  fi
  i=$((i+1))
done < $1 # parameters.lt



# declare -a arrPar=()
# i=0; j=0 #Starting reading fro line 5 | parItem = 1st Item, OtherItem=2nd item after splitting with '#'
# while IFS="#" read -r parItem OtherItem ; do
#   if [ $i -gt 5 ]; then
#     arrPar[j]=`echo $parItem | sed 's/ *$//g'`
#     echo -e "Line $i [$j]: $parItem => $OtherItem \t\tArr[$i] = ${arrPar[$j]}"
#     j=$((j+1))
#   fi
#   i=$((i+1))
# done < $1 # parameters.lt
