#!/bin/bash
# Remote update script for multiple Computers
# Synopsis:
#   update.sh [-n HostName]
#
# Requirements: 
#  - ssh and scp access to the Host(s)
#  - bash and the chosen Package Manager installed on the Host(s)
#  - sudo priviledges on the Host(s) for the username provided in Computers.txt
#  - localUpdate.sh present in the same folder as update.sh - Shell script to do the update work on the Host(s) - will be transfered with scp
#  - Computers.txt present in the same folder as update.sh - List of Host(s) with their connection options



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
runUpdate () {
    # function requires $ip,$port,$userName and $packageSystem to be set before running.
    echo "Running on $name with user $userName"
    scp -P $port ./localUpdate.sh "$userName"@"$ip":/home/"$userName"/localUpdate.sh
    if [ $packageSystem == "apt" ]
    then
        ssh $userName@$ip -p $port -t 'bash -l -c "./localUpdate.sh apt;bash"'
    elif [ $packageSystem == "paru" ]
    then
        ssh $userName@$ip -p $port -t 'bash -l -c "./localUpdate.sh paru;bash"'
    fi
}

# handle arguments
# for now n == name is the only valid option
# if option -n is provided the following argument should be the valid name of a PC from Computers.txt

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
# 2 dimensional array for all provided options for every Computer

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
            fi
    else
        for (( j=0; j<$numberOfOptions; j++)); do
            computerArray[$i,$j]=${computerValues[$j]}
        done
    fi
done

if [ ${#computerArray[*]} -eq $numberOfOptions ]
# this means that only 1 computer is in the array (a valid name was provided)
then
    name=${computerArray[0,0]}
    ip=${computerArray[0,1]}
    port=${computerArray[0,2]}
    userName=${computerArray[0,3]}
    packageSystem=${computerArray[0,4]}

    runUpdate
else
    # app needs to run through the entire computer list as no specific host was supplied.
    # there are more then 1 Computers options saved in computerArray
    for (( i=0; i<$numberOfComputers; i++ )); do
        name=${computerArray[$i,0]}
        ip=${computerArray[$i,1]}
        port=${computerArray[$i,2]}
        userName=${computerArray[$i,3]}
        packageSystem=${computerArray[$i,4]} 
    
        runUpdate
    done
fi