# Best Practices Reference

A portable quick-reference for MATLAB on Slurm HPC systems, with Expanse-specific
notes where indicated.

---

## Module Loading

> **[Expanse-specific]**

Always load in this exact order. The prerequisite applies even on GPU nodes.

```bash
module purge
module load cpu/0.15.4
module load matlab/2022a
```

---

## Template A: Interactive CLI Session

> **[Expanse-specific]** for account/partition; **[Portable]** for the pattern

```bash
# replace sds196 with your allocation
srun --account=sds196 \
     --partition=shared \
     --nodes=1 --ntasks=1 \
     --cpus-per-task=1 --mem=4G \
     --time=00:30:00 --pty bash

# Then on the compute node:
module purge
module load cpu/0.15.4
module load matlab/2022a
matlab -batch "run('$HOME/my_script.m')"
exit
```

---

## Template B: Array Job with Scratch, Timeout Reserve, and Copy-Back

> **[Expanse-specific]** for account/partition/scratch path; **[Portable]** for array and I/O logic

```bash
#!/bin/bash
#SBATCH --job-name=my_sweep
#SBATCH --account=sds196          # [Expanse-specific]
#SBATCH --partition=shared         # [Expanse-specific]
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=01:00:00            # include ~10 min reserve for tar + copy-back at end
#SBATCH --array=1-20              # [Portable] one task per hyperparameter set
#SBATCH --output=sweep_%A_%a.out  # [Portable]

module purge
module load cpu/0.15.4            # [Expanse-specific]
module load matlab/2022a          # [Expanse-specific]

# Node-local scratch — fast, per-job, auto-cleaned [Expanse-specific path]
WORKDIR=$TMPDIR/sweep_${SLURM_ARRAY_TASK_ID}
mkdir -p $WORKDIR
export WORKDIR

# Run MATLAB [Portable]
matlab -batch "run('$HOME/my_sweep.m')"  # ← replace with your .m file

# Aggregate and copy back [Portable]
OUTDIR=$HOME/results
mkdir -p $OUTDIR
tar -czf $OUTDIR/sweep_${SLURM_JOBID}_task_${SLURM_ARRAY_TASK_ID}.tar.gz \
    -C $WORKDIR .

# Clean up [Portable]
rm -rf $WORKDIR
```

---

## I/O Rules

> **[Portable]**

| Rule | Why |
|---|---|
| Write checkpoints to `$TMPDIR`, not `$HOME` | Prevents Lustre metadata storms |
| Aggregate with `tar` before copy-back | One large write beats many small writes |
| Clean up `$TMPDIR` at end of job | Good citizenship; Slurm cleans it anyway |
| Pass scratch path via `export WORKDIR` | Keeps shell and MATLAB in sync |
| Use `getenv('WORKDIR')` in MATLAB | Avoids hardcoded paths |

---

> **When to go beyond `matlab -batch`**
>
> The workflows in these guides use `matlab -batch` — one MATLAB process per job.
> This covers the majority of HPC use cases (parameter sweeps, independent training runs).
>
> If your workflow requires **shared memory parallelism within a single job**
> (e.g., `parfor` across workers, `parpool`), you need **MATLAB Parallel Server**:
>
> - Docs: https://www.mathworks.com/help/matlab-parallel-server/
> - `matlab -batch` → use when each job is independent (these guides)
> - `parpool` / `batch` → use when tasks share data within a job (requires MATLAB Parallel Server license)
>
> Check with your HPC center whether MATLAB Parallel Server is available before
> designing workflows that depend on it.

---

## Tag Legend

| Tag | Meaning |
|---|---|
| **[Expanse-specific]** | Applies to Expanse as configured; may differ on other systems |
| **[Portable]** | Works on any Slurm-scheduled HPC system with MATLAB installed |
