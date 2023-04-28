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

local マシンの~/.ssh/config を以下のように設定すると  
`ssh squid`

で接続できるようになります(2 要素認証・パスワードの入力は毎回必要)、VSCode からも飛べるようになります

```
Host squid
  HostName squidhpc.hpc.cmc.osaka-u.ac.jp
  User u*****
  ServerAliveInterval 60
  ServerAliveCountMax 3
```

squid で以下の設定を追加

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

http://www.hpc.cmc.osaka-u.ac.jp/system/manual/squid-use/jobclass/  
http://www.hpc.cmc.osaka-u.ac.jp/system/manual/squid-use/jobscript/#q

```
qsub --group=$GROUP_ID nqs.sh
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

## Singularity

http://www.hpc.cmc.osaka-u.ac.jp/lec_ws/20230126/  
http://www.hpc.cmc.osaka-u.ac.jp/system/manual/squid-use/singularity/  
https://docs.sylabs.io/guides/3.7/user-guide/index.html

注意  
By default, SingularityCE bind mounts /home/$USER, /tmp, and $PWD into your container at runtime.  
https://docs.sylabs.io/guides/latest/user-guide/quick_start.html#working-with-files

```
mkdir /sqfs/work//$GROUP_ID/$USER_ID/singularity_cache
echo "export SINGULARITY_CACHEDIR=/sqfs/work//$GROUP_ID/$USER_ID/singularity_cache" >> ~/.bashrc
source ~/.bashrc
# https://ngc.nvidia.com/setup/installers/cli
# https://ngc.nvidia.com/setup/api-key
echo "export SINGULARITY_DOCKER_USERNAME=$oauthtoken" >> ~/.bashrc
echo "export SINGULARITY_DOCKER_PASSWORD=<API Key> " >> ~/.bashrc
source ~/.bashrc

mkdir /sqfs/work/$GROUP_ID/$USER_ID/sif_images
# pytorchのversionについて: https://docs.nvidia.com/deeplearning/frameworks/support-matrix/index.html
singularity build /sqfs/work/$GROUP_ID/$USER_ID/sif_images/pytorch.sif docker://nvcr.io/nvidia/pytorch:23.04-py3
# 動作確認
# --nvの意味: https://docs.sylabs.io/guides/latest/user-guide/gpu.html#nvidia-gpus-cuda-legacy
singularity shell --nv /sqfs/work/$GROUP_ID/$USER_ID/sif_images/pytorch.sif
singularity run --nv /sqfs/work/$GROUP_ID/$USER_ID/sif_images/pytorch.sif python -c "import torch; print(torch.cuda.is_available()); print(torch.cuda.device_count())"
```

### Singularity イメージのカスタマイズ

基本は interactive job に入って sandbox を使用して環境作ってみて動作確認 →.sif 化する、install の手順を def に書き換える、みたいな感じか

#### sandbox から環境作成

https://docs.sylabs.io/guides/latest/user-guide/quick_start.html#sandbox-directories

```
cd /sqfs/work/$GROUP_ID/$USER_ID/sif_images
# TODO: なんのための処理
newgrp $GROUP_ID
# singularity help build
singularity build -f --sandbox --fix-perms mypytorch pytorch.sif
singularity run --nv -f -w mypytorch python -c "import torch; print(torch.cuda.is_available()); print(torch.cuda.device_count())"
# 色々インストール
pip install

# 環境書き出し
singularity build -f mypytorch.sif mypytorch
```

#### def ファイルから環境作成

https://docs.sylabs.io/guides/latest/user-guide/quick_start.html#singularityce-definition-files  
https://docs.sylabs.io/guides/latest/user-guide/definition_files.html#definition-files  
https://docs.sylabs.io/guides/latest/user-guide/quick_start.html#working-with-files  
https://docs.sylabs.io/guides/latest/user-guide/definition_files.html#best-practices-for-build-recipes

```
newgrp $GROUP_ID
singularity build -f /sqfs/work/$GROUP_ID/$USER_ID/sif_images/custom_env.sif custom_env.def
singularity shell /sqfs/work/$GROUP_ID/$USER_ID/sif_images/custom_env.sif
singularity run /sqfs/work/$GROUP_ID/$USER_ID/sif_images/custom_env.sif python
singularity run /sqfs/work/$GROUP_ID/$USER_ID/sif_images/custom_env.sif python -c "import torch; print(torch.cuda.is_available()); print(torch.cuda.device_count())"
singularity run --nv /sqfs/work/$GROUP_ID/$USER_ID/sif_images/custom_env.sif python -c "import torch; print(torch.cuda.is_available()); print(torch.cuda.device_count())"

singularity run /sqfs/work/$GROUP_ID/$USER_ID/sif_images/custom_env.sif python torch_test.py
singularity run --nv /sqfs/work/$GROUP_ID/$USER_ID/sif_images/custom_env.sif python torch_test.py
```

### batch job で実行

http://www.hpc.cmc.osaka-u.ac.jp/system/manual/squid-use/singularity/  
http://www.hpc.cmc.osaka-u.ac.jp/system/manual/squid-use/jobscript/#q  
http://www.hpc.cmc.osaka-u.ac.jp/system/manual/squid-use/scheduler/

```
qsub --group=$GROUP_ID job.sh
```

### batch job で実行(multi node)

TODO
