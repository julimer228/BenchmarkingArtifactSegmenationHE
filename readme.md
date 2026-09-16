# Benchmarking Artifact Segmentation Methods in H&E-Stained Whole Slide Imaging

[![arXiv](https://img.shields.io/badge/arXiv-XXXX.XXXXX-b31b1b.svg)](https://arxiv.org/abs/XXXX.XXXXX)
[![Preprint](https://img.shields.io/badge/Preprint-PDF-blue.svg)](https://arxiv.org/pdf/XXXX.XXXXX)
[![Tool](https://img.shields.io/badge/Tool-GitHub-black.svg)](https://github.com/USERNAME/TOOL-REPOSITORY)

This repository contains the code, experimental setup, and analysis associated with the benchmark paper:

> **[Full Paper Title]**
> [Author 1], [Author 2], [Author 3], ...
> *[Journal / Conference / Preprint, Year]*
> [arXiv:XXXX.XXXXX](https://arxiv.org/abs/XXXX.XXXXX)

## Overview

This study provides a systematic benchmark of several methods for **[briefly describe the task, e.g. histological image segmentation / nuclei detection / image analysis]**.

We compare the following methods:

* **[Method 1]**
* **[Method 2]**
* **[Method 3]**
* **[Method 4]**
* **[Your method/tool, if applicable]**

The benchmark evaluates the methods across **[datasets / experimental conditions / preprocessing settings]** using metrics including **[Dice, sensitivity, FDR, etc.]**.

The goal of this repository is to provide the code and analysis required to reproduce the results reported in the paper.

## Paper / Preprint

The preprint is available on arXiv:

**[Paper Title](https://arxiv.org/abs/XXXX.XXXXX)**

PDF:

**[Download the preprint](https://arxiv.org/pdf/XXXX.XXXXX)**

## Associated Tool

The tool used/developed in this study is available in a separate repository:

**[Tool Name](https://github.com/USERNAME/TOOL-REPOSITORY)**

The tool repository contains **[brief description, e.g. the implementation, installation instructions, command-line interface, and usage examples]**.

## Repository Structure

```text
.
├── data/                   # Data or processed benchmark results
├── scripts/                # Benchmark and processing scripts
├── statistical_analysis/   # Statistical analyses
├── plots/                  # Figures generated from the benchmark
├── results/                # Benchmark results
└── README.md
```

> **Note:** The exact structure may differ depending on the version of the repository.

## Reproducing the Benchmark

### 1. Clone the repository

```bash
git clone https://github.com/USERNAME/BENCHMARK-REPOSITORY.git
cd BENCHMARK-REPOSITORY
```

### 2. Install dependencies

Describe the required environment and dependencies here.

For example:

```bash
# Example
pip install -r requirements.txt
```

or:

```bash
conda env create -f environment.yml
conda activate BENCHMARK_ENV
```

### 3. Run the benchmark

```bash
# Add benchmark command(s) here
```

### 4. Statistical analysis

The statistical analyses and scripts used to generate the figures reported in the paper are available in:

```text
statistical_analysis/
```

## Datasets

The benchmark was performed using the following datasets:

| Dataset     | Description         | Reference / Link |
| ----------- | ------------------- | ---------------- |
| Dataset A | [Short description] | [Link]           |
| Dataset B | [Short description] | [Link]           |
| Dataset C (ours) | [Short description] | [Link]           |

Please refer to the paper for the complete description of dataset preparation, inclusion criteria, and experimental settings.

## Citation

If you use this benchmark, code, or results in your research, please cite our paper:

```bibtex
@article{merta2026,
  title   = {Benchmarking Artifact Segmentation Methods in H&E-Stained Whole Slide Imaging},
  author  = {Merta, Julia and Polanska, Joanna and Marczyk, Michał},
  journal = {arXiv preprint arXiv:XXXX.XXXXX},
  year    = {2026},
  eprint  = {XXXX.XXXXX},
  archivePrefix = {arXiv},
  primaryClass   = {[e.g. cs.CV]},
  url     = {https://arxiv.org/abs/XXXX.XXXXX}
}
```

If you specifically use **HistoKit**, please also refer to its repository:

**https://github.com/USERNAME/TOOL-REPOSITORY**

## Results

A detailed description and discussion of the benchmark results can be found in the paper.

Key results include:

* **HistoKit achieved similar or better results for each metric than GrandQC across all datasets. ****
* **Deep-learning methods trained on diverse datasets performed better than methods based on image quality metrics and thresholding-based methods.**
* **Simple post-processing further improved segmentation quality produced by HistoKit**

## License

This repository is released under the **[MIT / Apache-2.0 / GPL-3.0 / other]** license. See [`LICENSE`](LICENSE) for details.

Please note that the datasets and benchmarked third-party methods may be distributed under their own licenses.

## Contact

For questions regarding the benchmark or the paper, please contact:

**Julia Merta**
- Department of Data Science and Engineering
- Silesian University of Technology
- 📧 [julia.merta@polsl.pl](mailto:julia.merta@polsl.pl)

