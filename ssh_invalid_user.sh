#!/bin/bash
# Lists invalid users from auth.log
cat /var/log/auth.log | grep "Invalid user"
