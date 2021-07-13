#!/usr/bin/env bash
if test "`echo -e`" = "-e" ; then ECHO=echo ; else ECHO="echo -e" ; fi

# cd vcpHdpEcoCluster & Give execute permission to the script:  chmod +x run.sh
# run: ./run.sh VAG X N 1 3 | Optins: platType[VAG AWS AZURE] StackExt[A..Z] isBastion[N Y] NumMasters[1, 2, 3, 4, 5] NumSlaves[1, 3, 5, 7]
# export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -i AnsibleInventory bdplat_pb.yml
# ssh LogHost

source AduraxFtns.sh
sTime=$(date +%s)

#[** Parameter Input Validation
platType=${1:-VAG} # platType Options: [VAG | AWS | AZURE]
inputValidation  "VAG AWS AZURE" $platType "platType" && platType=$Inputs # Input validation for host type
if [ $platType = "VAG" ]; then hostDir=Vagrant; elif [ $platType = "AWS" ]; then hostDir=AWS; else hostDir=Azure; fi

#**] Parameter Input Validation

if test -f "Platforms/$platType/StackNameFile"; then
#[** Check for exist of Big Data Cluster  for delete
StackName=$(cat Platforms/$platType/StackNameFile)
$ECHO "\nDo you want to DELETE \"$StackName\" Big Data cluster stack? \nType \"y\" for yes or any other character for no and press [ENTER]:"
read doDelete
  if [ $doDelete = "y" ] || [ $doDelete = "Y" ]; then
    $ECHO "\n**** Deleting the stack ....."
    if [ $platType = "VAG" ]; then
      echo delete vagrant $StackName
    elif [ $platType = "AWS" ]; then
      aws cloudformation delete-stack --stack-name $StackName #To delete the stack
    else
      echo delete Azure $StackName
    fi

    rm connect.sh nodes.yaml AnsibleInventory Platforms/$platType/StackNameFile Platforms/$platType/template.yaml
  else
    $ECHO "\n**** No worries! Exiting...\n"
    cd .. && exit
  fi
#**] Check for exist of Big Data Cluster for delete

else
#[** Other Parameter Input Validation
StackExt=${2:-X}    # StackNameExt Options: [Any single letter character {A..Z}]
inputValidation "\" $(echo {A..Z}) \""  $StackExt "StackExt" && StackExt=$Inputs
isBastion=${3:-N}   # isBastion  Options: [Do you need bastion host? Yes: Y | No: N]
inputValidation "Y N" $isBastion "isBastion" && isBastion=$Inputs

declare -i NumMasters=${4:-1} NumSlaves=${5:-3} Num
Indx=0
while [ $Indx -lt 3 ]
do
  Indx=$(( Indx+1 ))
  if [ $Indx -ne 1 ]; then
    $ECHO "Type in NumMasters and press [ENTER]:" && read NumMasters
    $ECHO "Type in NumSlaves  and press [ENTER]:" && read NumSlaves
  fi

  Num=NumSlaves #&& $ECHO "The number master: NumSlaves  and slave hosts: $Num"
  Num=$(expr $Num % 2)
  if [[ $Num -eq 1 ]]; then
    $ECHO "Correct inputs ..."
    break
  else
    if [ $Indx -eq 3 ]; then
      $ECHO "\nInvalid input exiting after the third attempt...\n"
      exit
    else
      $ECHO "Invalid input try again. The number of master nodes must be 1, 3, 5 or 7 ...\n"
    fi
  fi
done
#**] Other Parameter Input Validation

$ECHO "Changing directory from [`pwd`] => "
cd Platforms/$platType
$ECHO "to [`pwd`] \n\nRunning hostRun.sh ... \n\nThe Cluster Stack Info:"
chmod +x hostRun.sh
./hostRun.sh $platType $StackExt $isBastion $NumMasters $NumSlaves

cd ../..
./connect.sh
fi

timeDiff $sTime $(date +%s)
