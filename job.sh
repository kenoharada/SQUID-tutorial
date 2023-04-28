#!/bin/bash
#PBS -q SQUID
#PBS -l elapstim_req=1:00:00
#PBS -l gpunum_job=8
cd $PBS_O_WORKDIR
export SINGULARITY_BIND="`readlink -f /sqfs/work/$GROUP_ID/$USER`,$PBS_O_WORKDIR"
nvidia-smi
singularity run /sqfs/work/$GROUP_ID/$USER_ID/sif_images/custom_env.sif python -c "import torch; print(torch.cuda.is_available()); print(torch.cuda.device_count())"
singularity run --nv /sqfs/work/$GROUP_ID/$USER_ID/sif_images/custom_env.sif python -c "import torch; print(torch.cuda.is_available()); print(torch.cuda.device_count())"

singularity run /sqfs/work/$GROUP_ID/$USER_ID/sif_images/custom_env.sif python torch_test.py
singularity run --nv /sqfs/work/$GROUP_ID/$USER_ID/sif_images/custom_env.sif python torch_test.py