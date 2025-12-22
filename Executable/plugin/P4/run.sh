#!/bin/bash
cd /crypto_scout/plugin/P4
java allow1 >> output.txt
java allow2 >> output.txt
python3 P4.pyc 2>&1 | tee output.csv
#python3 P4.py > output.csv
python3 mergeCell.pyc 
rm -f inconsist_allow_res_total.csv
rm -f inconsist_allow_res_update_total.csv
rm -f addr_tx_amount_ultimate_without_less_total.csv
rm -f output.csv
rm -f output.txt
cp 'Inconsisten transferFrom().xlsx' ../ 
