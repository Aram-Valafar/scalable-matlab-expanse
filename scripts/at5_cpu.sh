#!/bin/bash
#SBATCH --job-name=at5_cpu
#SBATCH --account=sds196
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=00:15:00
#SBATCH --output=at5_cpu_%j.out

module purge
module load cpu/0.15.4
module load matlab/2022a

export WORKDIR=$TMPDIR

matlab -batch "run('$HOME/scalable-matlab-expanse/scripts/at5_ann.m')"
