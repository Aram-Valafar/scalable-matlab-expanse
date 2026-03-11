#!/bin/bash
#SBATCH --job-name=at5_gpu
#SBATCH --account=sds196
#SBATCH --partition=gpu-shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --gpus=1
#SBATCH --time=00:15:00
#SBATCH --output=at5_gpu_%j.out

module purge
module load cpu/0.15.4
module load matlab/2022a

export WORKDIR=$TMPDIR

matlab -batch "run('$HOME/scalable-matlab-expanse/scripts/at5_ann.m')"
