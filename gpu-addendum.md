# GPU & AI Workflow Addendum

Lightweight reference for running MATLAB Deep Learning Toolbox jobs on Expanse GPUs.
Read M1–M4 first. **Setup:** [Clone the repo to Expanse first](README.md#getting-started) — scripts referenced below live in `scripts/`.

---

## Steps

### Step 1: Submit a CPU baseline job
> **[Expanse-specific]** for account/partition; **[Portable]** for MATLAB code

Submit the CPU version to establish a baseline:

```bash
sbatch ~/scalable-matlab-expanse/scripts/at5_cpu.sh
```

This uses `scripts/at5_cpu.sh` + `scripts/at5_ann.m`. Key settings:

```bash
#SBATCH --partition=shared
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
```

No `--gpus` flag. MATLAB detects no GPU and trains on CPU automatically.

### Step 2: Submit a single-GPU job
> **[Expanse-specific]**

Submit the GPU version using the same `.m` file:

```bash
sbatch ~/scalable-matlab-expanse/scripts/at5_gpu.sh
```

This uses `scripts/at5_gpu.sh`. Key settings:

```bash
#SBATCH --partition=gpu-shared
#SBATCH --gpus=1
#SBATCH --mem=16G
```

> **Important:** GPU nodes on Expanse still require `module load cpu/0.15.4` before
> `module load matlab/2022a`. Do **not** use `gpu/0.15.4` as the prerequisite —
> MATLAB bundles its own CUDA runtime.

```bash
module purge
module load cpu/0.15.4     # required even on GPU nodes
module load matlab/2022a
```

### Step 3: Compare outputs
> **[Portable]**

Check the output files from both jobs:

```bash
cat at5_cpu_<your_job_id>.out
cat at5_gpu_<your_job_id>.out
```

The GPU job should show `AT5: GPU detected` and train with `(gpu)` execution environment.
The CPU job should show `AT5: No GPU detected` and train with `(cpu)`.

---

## Pass/Fail Check

- ✅ **PASS (GPU):** Output contains `AT5: GPU detected` and training table shows `(gpu)` execution environment
- ✅ **PASS (CPU):** Output contains `AT5: No GPU detected` and training completes on CPU
- ❌ **FAIL — No GPU detected on GPU node:** Confirm `--partition=gpu-shared` and `--gpus=1` are set in your sbatch script
- ❌ **FAIL — module error:** Confirm you used `cpu/0.15.4` (not `gpu/0.15.4`) as the prerequisite

**Expected GPU output snippet** (GPU model may vary by node; V100 is typical on Expanse `gpu-shared`):
```
AT5: GPU detected — Tesla V100-SXM2-32GB
AT5: GPU available memory: 33.55 GB
AT5: Training MLP (gpu)...
```

---

## Non-CNN ANN Example (MLP)

The example in `scripts/at5_ann.m` demonstrates a fully-connected feedforward
network (MLP) — not a CNN or RNN. This architecture is common in:

- Regression from tabular/sensor data (aerospace, robotics)
- Surrogate models for simulation
- Policy approximation in reinforcement learning

**Architecture used:**

```
featureInputLayer(20)
  → fullyConnectedLayer(128) → reluLayer
  → fullyConnectedLayer(64)  → reluLayer
  → fullyConnectedLayer(1)
  → regressionLayer
```

**Adapting for your use case:**
- Change `numFeatures` to match your input dimension
- Change the final `fullyConnectedLayer(1)` output size for multi-output regression
- Replace `regressionLayer` with `softmaxLayer` + `classificationLayer` for classification

---

## GPU Detection in MATLAB

> **[Portable]**

The same script (`at5_ann.m`) runs on CPU or GPU — it auto-detects:

```matlab
if gpuDeviceCount > 0
    execEnv = 'gpu';
    g = gpuDevice(1);
    fprintf('GPU: %s\n', g.Name);
else
    execEnv = 'cpu';
end

opts = trainingOptions('adam', 'ExecutionEnvironment', execEnv, ...);
```

Submit the same `.m` file with either `at5_cpu.sh` or `at5_gpu.sh` — no code changes needed.
