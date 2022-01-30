#!/bin/bash

# Constant values
ComputerListFile='./Computers'


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
            n) computername=${OPTARG};;
        esac
    done
    echo "Computername : $computername";
fi

readComputerList

for computer in ${computers[@]}; do
    getComputerValues $computer
    if [ -n "${computername}" ]
    then
        if (( "${computerValues[$1]}" == "${computername}" ));
        then
            for i in ${!computerValues[@]}; do
                echo "element $i of Computer '${computerValues[$1]}' is ${computerValues[$i]} current Value of Computername : ${computername}"
            done
        fi
    else
        echo "${computerValues[*]}"
    fi
done






