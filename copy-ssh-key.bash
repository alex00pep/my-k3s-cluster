#!/bin/bash


# Check if SSH Agent is running. 
eval "$(ssh-agent -s)"
# Add the Keys to SSH Agent. 
ssh-add $1
# Verify Keys Added to SSH Agent.
ssh-add -l


xargs -a inventory -t -I {} -n 1 ssh-copy-id -i "$1" -f pi@{}