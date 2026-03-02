# M3: Scalable Job Arrays

**Time:** ~15 min | **Prerequisites:** [M2](M2-interactive-cli.md)

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
#SBATCH --account=sds196          # [Expanse-specific]
#SBATCH --partition=shared         # [Expanse-specific]
#SBATCH --array=1-5               # [Portable]
#SBATCH --output=at2_%A_%a.out    # [Portable]
```

MATLAB reads its task ID:

```matlab
task_id = str2num(getenv('SLURM_ARRAY_TASK_ID'));
fprintf('Task %d running\n', task_id);
```

### Step 3: Submit the array
> **[Expanse-specific]**

```bash
sbatch scripts/at2_array.sh
```

Slurm returns a single job ID (e.g., `46860050`). All 5 tasks run under this ID
as `46860050_1` through `46860050_5`.

### Step 4: Monitor progress
> **[Expanse-specific]**

```bash
squeue -u $USER
```

You will see each task listed separately with its own node assignment.

### Step 5: Verify all tasks completed
> **[Portable]**

```bash
sacct -j 46860050 --format=JobID,State
```

**Expected output:**
```
JobID             State
------------ ----------
46860050_1    COMPLETED
46860050_2    COMPLETED
46860050_3    COMPLETED
46860050_4    COMPLETED
46860050_5    COMPLETED
```

### Step 6: Check per-task outputs
> **[Portable]**

```bash
cat at2_46860050_*.out
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
