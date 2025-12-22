#!/bin/bash
cd /crypto_scout/plugin/P3
python3 P3_step1.pyc > step1_output
python3 P3_step2.pyc 2>&1 | tee step2_output
python3 P3_step3.pyc 
rm -r step1_output step2_output
cp Misleading_dex.xlsx ../