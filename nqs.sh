#!/bin/bash
#PBS -q SQUID
#PBS -l elapstim_req=1:00:00
module load BaseCPU
cd $PBS_O_WORKDIR
python sample.py