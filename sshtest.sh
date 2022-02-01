#!/bin/bash

ssh nas -t 'bash -l -c "./localUpdate.sh apt;bash"'
ssh tv1 -t 'bash -l -c "./localUpdate.sh paru;bash"' 