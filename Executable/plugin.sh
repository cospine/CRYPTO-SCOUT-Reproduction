#!/usr/bin/env bash
# P3: Misleading DEX Attacks
# P4: Inconsistent transferFrom()
# P5: Unauthorized Token Burning
while getopts :p:m:i:u: opts; do
    case $opts in
        i) plugin=$OPTARG ;; # p3 p4 p5
        ?) printf "Usage: %s  [-i P3\P4\P5] " $0;;
    esac
done
if [ "$plugin" = "P3" ]
then
      chmod +x /crypto_scout/plugin/P3/run.sh
      exec /crypto_scout/plugin/P3/run.sh
fi

if [ "$plugin" = "P4" ]
then
        chmod +x /crypto_scout/plugin/P4/run.sh
        exec /crypto_scout/plugin/P4/run.sh
fi

if [ "$plugin" = "P5" ]
then
        chmod +x /crypto_scout/plugin/P5/run.sh
        exec /crypto_scout/plugin/P5/run.sh
fi