#!/bin/bash

# Constant values
ComputerListFile='./Computers.txt'
numberOfOptions=5

# function definitions
readComputerList () {
    IFS=$'\n' computers=( $( cat $ComputerListFile))
}
getComputerValues () {
    # expects a string seperated by ',' as input
    IFS=',' read -r -a computerValues <<< "$1"
}

# handle arguments
# for now n == name is the only valid option
# if option -n is provided the following argument should be the valid name of a PC from Computers

if [ -n "$1" ] 
then
# if any arguments are supplied get the Computername from the option -n
    while getopts n: flag
    do
        case "${flag}" in
            n) computerName=${OPTARG};;
        esac
    done
fi

declare -A computerArray

readComputerList

numberOfComputers=${#computers[*]};

for (( i=0; i<$numberOfComputers; i++ )); do
    getComputerValues ${computers[$i]}
    if [ $computerName ];
    then
        if [ ${computerValues[0]} == $computerName ]
        then
            for (( j=0; j<$numberOfOptions; j++)); do
                computerArray[0,$j]=${computerValues[$j]}
            done
            echo "Die IP von ${computerArray[0,0]} = ${computerArray[0,1]}"
        fi
    else
        for (( j=0; j<$numberOfOptions; j++)); do
            computerArray[$i,$j]=${computerValues[$j]}
        done
        echo "Die IP von ${computerArray[$i,0]} = ${computerArray[$i,1]} Paketverwaltung: ${computerArray[$i,4]}"
    fi
done

if [ ${#computerArray[*]} -eq $numberOfOptions ]
# this means that only 1 computer is in the array (a valid name was provided)
then
    ip=${computerArray[0,1]}
    port=${computerArray[0,2]}
    userName=${computerArray[0,3]}
    packageSystem=${computerArray[0,4]}

    scp -P $port /home/martin/code/bash/projects/updates/localUpdate.sh "$ip":/home/"$userName"/localUpdate.sh

    if [ $packageSystem == "apt" ]
    # this means that only 1 computer is in the array (a valid name was provided)
    then
        ssh $userName@$ip -p $port -t 'bash -l -c "./localUpdate.sh apt;bash"'
    elif [ $packageSystem == "paru" ]
    then
        ssh $userName@$ip -p $port -t 'bash -l -c "./localUpdate.sh paru;bash"'
    fi
fi