# 🔬 Benchmarking Artifact Segmentation Methods in H&E-Stained Whole Slide Imaging

[![arXiv](https://img.shields.io/badge/arXiv-XXXX.XXXXX-b31b1b.svg)](https://arxiv.org/abs/XXXX.XXXXX)
[![Preprint](https://img.shields.io/badge/Preprint-PDF-blue.svg)](https://arxiv.org/pdf/XXXX.XXXXX)
[![Tool](https://img.shields.io/badge/Tool-GitHub-black.svg)](https://github.com/USERNAME/TOOL-REPOSITORY)

This repository contains the code, experimental setup, and analysis associated with the benchmark paper:

> **Benchmarking Artifact Segmentation Methods in H&E-Stained Whole Slide Imaging**
> Julia Merta, Joanna Polańska, Michał Marczyk, ...
> *[Journal / Conference / Preprint, Year]*
> [arXiv:XXXX.XXXXX](https://arxiv.org/abs/XXXX.XXXXX)

## Overview

This study provides a systematic benchmark of several methods for artifact segmentation and classification of the following classes of artifacts:

* **Tissue** – tissue regions without artifacts.
* **Background** – pixels corresponding to the slide background. For Dataset A, in the binary classification task, this class also includes pixels corresponding to tissue and other artifact types.
* **Dark Spot** - dark regions caused by foreign objects, such as dust particles and hair, or by non-uniform illumination.
* **Edge** - artifacts including coverslip edges, air bubbles, and cracked glass.
* **Fold** – regions containing tissue folds.
* **Out-of-Focus** - image regions affected by blurring caused by the scanner movement being too fast or other factors.
* **Pen** - regions containing pen or marker traces of various colors.

## 🔎 Compared Histopathology Quality Control Tools
<table width="100%">
  <thead>
    <tr>
      <th width="40%">Tool / Method</th>
      <th width="30%">💻 Repository</th>
      <th width="30%">📄 Paper</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>GrandQC</strong></td>
      <td><a href="https://github.com/cpath-ukk/grandqc">Repository</a></td>
      <td><a href="https://www.nature.com/articles/s41467-024-54769-y">Paper</a></td>
    </tr>
    <tr>
      <td><strong>HistoKit</strong></td>
      <td><a href="https://github.com/ZAEDPolSl/HistoKit/tree/main">Repository</a></td>
      <td><a href="https://doi.org/10.5220/0000222000004070">Paper</a></td>
    </tr>
    <tr>
      <td><strong>HistoQC</strong></td>
      <td><a href="https://github.com/choosehappy/HistoQC">Repository</a></td>
      <td><a href="https://andrewjanowczyk.com/wp-content/uploads/2019/04/HistoQC_w_supplemental.pdf">Paper</a></td>
    </tr>
    <tr>
      <td><strong>HistoROI</strong></td>
      <td><a href="https://github.com/abhijeetptl5/historoi">Repository</a></td>
      <td><a href="https://pmc.ncbi.nlm.nih.gov/articles/PMC10113897/">Paper</a></td>
    </tr>
    <tr>
      <td><strong>Patil et al. (2025)</strong></td>
      <td><a href="https://github.com/abhijeetptl5/wsisegqc">Repository</a></td>
      <td><a href="https://arxiv.org/pdf/2410.03289">Paper</a></td>
    </tr>
    <tr>
      <td><strong>Schreiber et al. (2024)</strong></td>
      <td><a href="https://gitlab.developers.cam.ac.uk/bas43/h_and_e_otsu_thresholding">Repository</a></td>
      <td><a href="https://www.nature.com/articles/s41598-023-50183-4">Paper</a></td>
    </tr>
  </tbody>
</table>


The benchmark evaluates the methods across three manually annotated datasets using metrics including Dice, sensitivity, FDR for tissue versus artifact and background segmentation for all the methods. For GrandQC, HistoKit, and Patil et al. (2025), we also analyze Dice per artifact class.

## 💾 Datasets

The benchmark was performed using the following datasets:

| Dataset     | Description         | Reference / Link |
| ----------- | ------------------- | ---------------- |
| Dataset A | [Short description] | [Link]           |
| Dataset B | [Short description] | [Link]           |
| Dataset C (ours) | [Short description] | [Link]           |

Please refer to the paper for the complete description of dataset preparation, inclusion criteria, and experimental settings.

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

**[HistoKit](https://github.com/ZAEDPolSl/HistoKit/tree/main/src/histokit/)**

## Results

The paper provides a detailed description and discussion of the benchmark results.

Key results include:

* **HistoKit achieved similar or better results for each metric than GrandQC across all datasets.**
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

