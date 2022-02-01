#!/bin/bash

if [ -n "$1" ] 
then
    if [ $1 == "apt" ]
    then
        sudo apt-get update && sudo apt-get dist-upgrade
    elif [ $1 == "paru" ]
    then
        paru
    else
        echo "unbekannter Parameter $1"
    fi
fi
