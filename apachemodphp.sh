#!/bin/bash
echo "Search for available php mod..."
apt-cache show libapache2-mod-php | grep Depends | cut -d ' ' -f2
