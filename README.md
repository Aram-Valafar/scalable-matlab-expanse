# Scalable MATLAB on Expanse

Beginner-safe micro-guides for running MATLAB on the Expanse HPC cluster for AI/ML workflows.

## Prerequisites

- Comfortable with Linux command line basics
- No prior HPC experience required
- MATLAB user (desktop background assumed)

## System Information

| Resource | Value |
|----------|-------|
| System | Expanse (SDSC) |
| Allocation | sds196 |
| MATLAB Version | 2022a |
| Portal | https://portal.expanse.sdsc.edu |

## Guide Map

| Guide | Title | Time |
|-------|-------|------|
| [M1](M1-preflight.md) | Pre-flight & GUI→CLI Migration | ~10 min |
| [M2](M2-interactive-cli.md) | Interactive CLI MATLAB | ~10 min |
| [M3](M3-arrays.md) | Scalable Job Arrays | ~15 min |
| [M4](M4-io-patterns.md) | Storage & I/O Patterns | ~15 min |
| [M5](M5-portal.md) | Portal MATLAB (GUI) | ~10 min |
| [Best Practices](best-practices.md) | One-Pager Reference | — |
| [GPU Addendum](gpu-addendum.md) | GPU & AI Workflows | — |

## Getting Started

### 1. Clone this repo to Expanse

From the [portal shell](https://portal.expanse.sdsc.edu) (Expanse Shell Access):

```bash
git clone https://github.com/Aram-Valafar/scalable-matlab-expanse.git ~/scalable-matlab-expanse
cd ~/scalable-matlab-expanse
```

All guides reference scripts in the `scripts/` directory — this clone puts them on Expanse where you can run them.

### 2. Verify your access

```bash
groups                        # should show sds196
module load cpu/0.15.4 && module load matlab/2022a
matlab -batch "disp(version)" # should print 9.12.0.1884302 (R2022a)
```

## Tag Legend

| Tag | Meaning |
|-----|---------|
| `[Expanse-specific]` | Instruction applies to Expanse as configured; may differ on other systems |
| `[Portable]` | Works on any Slurm-scheduled HPC system with MATLAB installed |

## Acknowledgments

This project was developed as part of the NAIRR CIP Fellow program in collaboration with the San Diego Supercomputer Center (SDSC).
