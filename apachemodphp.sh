#!/bin/bash
echo "Search for available php mod..."
_mod-ver=$(apt-cache show libapache2-mod-php | grep Depends | cut -d ' ' -f2)
echo "Found '$_mod-ver'"
echo " Need to call apt install libapaceh2-mod-$_mod-ver"
