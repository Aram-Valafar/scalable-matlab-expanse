# M3: Scalable Job Arrays

**Time:** ~15 min | **Prerequisites:** [M2](M2-interactive-cli.md) | **Setup:** [Clone the repo to Expanse first](README.md#getting-started)

## What you'll do

Submit N independent MATLAB jobs as a single Slurm array, verify all complete,
and check per-task outputs — the standard pattern for hyperparameter sweeps and
Monte Carlo runs.

## Steps

### Step 1: Understand array jobs
> **[Portable]**

A job array submits N copies of the same script. Slurm assigns each copy a unique
`SLURM_ARRAY_TASK_ID` (1 through N). Use this ID to differentiate tasks — for
example, to select a different hyperparameter value per task.

Output files use `%A` (array job ID) and `%a` (task ID) to avoid overwriting:

```
#SBATCH --array=1-5
#SBATCH --output=job_%A_%a.out
```

### Step 2: The array job script
> **[Expanse-specific]** for account/partition; **[Portable]** for array logic

See `scripts/at2_array.sh` in this repo. Key lines:

```bash
#SBATCH --account=sds196          # [Expanse-specific] — edit if your allocation differs
#SBATCH --partition=shared         # [Expanse-specific]
#SBATCH --array=1-5               # [Portable]
#SBATCH --output=at2_%A_%a.out    # [Portable]
```

MATLAB reads its task ID:

```matlab
task_id = str2num(getenv('SLURM_ARRAY_TASK_ID'));
fprintf('AT2 task %d complete\n', task_id);
```

> **Note:** Single-line MATLAB is fine inline in the shell command; use `.m` files
> for multi-line logic (see M2 Step 4).

### Step 3: Submit the array
> **[Expanse-specific]**

From the login node (exit any `srun` session first):

```bash
sbatch ~/scalable-matlab-expanse/scripts/at2_array.sh
```

Slurm returns a single job ID (e.g., `12345678`). All 5 tasks run under this ID
as `12345678_1` through `12345678_5`.

### Step 4: Monitor progress
> **[Portable]**

```bash
squeue -u $USER
```

You will see each task listed separately with its own node assignment.

### Step 5: Verify all tasks completed
> **[Portable]**

Replace `<your_job_id>` with the ID that `sbatch` printed:

```bash
sacct -j <your_job_id> --format=JobID,State
```

**Expected output** (your job ID will differ; you may also see `.batch` sub-step lines — these are normal):
```
JobID             State
------------ ----------
<jobid>_1     COMPLETED
<jobid>_2     COMPLETED
<jobid>_3     COMPLETED
<jobid>_4     COMPLETED
<jobid>_5     COMPLETED
```

### Step 6: Check per-task outputs
> **[Portable]**

Output files are created in the directory where you ran `sbatch`. Replace `<your_job_id>` with your job ID:

```bash
cat at2_<your_job_id>_*.out
```

**Expected output:**
```
AT2 task 1 complete
AT2 task 2 complete
AT2 task 3 complete
AT2 task 4 complete
AT2 task 5 complete
```

> **Note:** When to use more tasks: replace `--array=1-5` with `--array=1-N` where N
> matches your sweep size (e.g., 20 hyperparameter combinations = `--array=1-20`).

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

## Pass/Fail Check

- ✅ **PASS:** `sacct` shows all 5 tasks COMPLETED and each output file contains `AT2 task N complete`
- ❌ **FAIL — tasks FAILED:** Check individual output files (`cat at2_<jobid>_1.out`) for error messages
- ❌ **FAIL — output files missing:** Confirm `--output=at2_%A_%a.out` uses `%A` and `%a`, not `%j`

**Next:** [M4 — Storage & I/O Patterns](M4-io-patterns.md)
