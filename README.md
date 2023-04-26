# SQUID-tutorial

Learn how to use SQUID(http://www.hpc.cmc.osaka-u.ac.jp/squid/) step by step
Resources
http://www.hpc.cmc.osaka-u.ac.jp/system/manual/squid-use/  
http://www.hpc.cmc.osaka-u.ac.jp/wp-content/uploads/2021/05/SQUID_user_manual.pdf

## login

http://www.hpc.cmc.osaka-u.ac.jp/system/manual/squid-use/login/

```
ssh u*****@squidhpc.hpc.cmc.osaka-u.ac.jp
```

```
Host squid
  HostName squidhpc.hpc.cmc.osaka-u.ac.jp
  User u*****
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

```
# check your user/group id
id
# set GROUP_ID, USER_ID
echo 'export GROUP_ID=G*****' >> ~/.bashrc
echo 'export USER_ID=u*****' >> ~/.bashrc

source ~/.bashrc
```

## interactive job

http://www.hpc.cmc.osaka-u.ac.jp/system/manual/squid-use/interactive/

```
# GPU8枚挿を10分
qlogin -q INTG -l elapstim_req=00:10:00,gpunum_job=8 --group=$GROUP_ID

nvidia-smi
```

## batch job

http://www.hpc.cmc.osaka-u.ac.jp/system/manual/squid-use/jobscript/

```
qsub --group $GROUP_ID nqs.sh
```

## conda

http://www.hpc.cmc.osaka-u.ac.jp/faq/20211108/

```
# Anaconda仮想環境の作成準備
conda config --add envs_dirs /sqfs/work/$GROUP_ID/$USER_ID/conda_env
conda config --add pkgs_dirs /sqfs/work/$GROUP_ID/$USER_ID/conda_pkg

#Pytorchをインストールする仮想環境 torch-envを作成し、Activateする
conda create --name torch-env python=3.8
conda activate torch-env

# SQUIDのGPUノード(A100)に対応するCUDA11.1 + Pytorchをインストール TODO: GPUノードのCUDA versionとかの確認
# https://pytorch.org/
conda install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia

python -c "import torch; print(torch.cuda.is_available()); print(torch.cuda.device_count())"
```

```
qlogin -q INTG -l elapstim_req=00:10:00,gpunum_job=8 --group=$GROUP_ID
conda activate torch-env
python -c "import torch; print(torch.cuda.is_available()); print(torch.cuda.device_count())"
```

## singularity

http://www.hpc.cmc.osaka-u.ac.jp/lec_ws/20230126/
http://www.hpc.cmc.osaka-u.ac.jp/system/manual/squid-use/singularity/
https://docs.sylabs.io/guides/3.7/user-guide/index.html

```

```
