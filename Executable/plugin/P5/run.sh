#!/bin/bash
cd /crypto_scout/plugin/P5
java burn >> output.txt
python3 process.pyc >> output.txt
python3 P5.pyc
rm -f inconsist_burn_withoutAllow_sheet1.csv
rm -f inconsist_burn_withoutAllow_sheet2.csv
rm -f burn.xlsx
rm -f output.txt
cp 'Unauthorized Token Burning.xlsx' ../ 
