# 🔬 Benchmarking and Improvement of Artifact Segmentation Methods in H&E-Stained Whole Slide Imaging

[![arXiv](https://img.shields.io/badge/arXiv-XXXX.XXXXX-b31b1b.svg)](https://arxiv.org/abs/XXXX.XXXXX)
[![Preprint](https://img.shields.io/badge/Preprint-PDF-blue.svg)](https://arxiv.org/pdf/XXXX.XXXXX)

This repository contains the code associated with the benchmark paper:

📄 Benchmarking and Improvement of Artifact Segmentation Methods in H&E-Stained Whole Slide Imaging

Authors: Julia Merta, Daniel Mendelsohn, Benedikt Schoser, Joanna Polańska, Michał Marczyk
[Preprint] · arXiv.XXXXX

## ✨ Graphical Abstract

<img width="1793" height="950" alt="image" src="https://github.com/user-attachments/assets/7f82cc92-4879-473b-bb7e-988cde379fd0" />



## ✨ Highlights

- 🔬 First multi-dataset benchmark of public artifact segmentation methods for HE-stained WSIs.
- ⚡ Six artifact segmentation methods were compared for quality and processing speed.
- 🧬 A new public multi-source, multi-organ dataset with pixel-level annotations is introduced.
- 📊 Significant performance differences were found, with HistoKit performing best overall.
- 🛠️ A post-processing method for HistoKit improved artifact segmentation performance.

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
      <th width="33.33%">Tool / Method</th>
      <th width="33.33%">💻 Repository</th>
      <th width="33.33%">📄 Paper</th>
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


The benchmark evaluates the methods across three manually annotated datasets using metrics including Dice, sensitivity, and FDR for tissue versus artifact and background segmentation for all the methods. For GrandQC, HistoKit, and Patil et al. (2025), we also analyze Dice per artifact class.

## 💾 Datasets

The benchmark was performed using the following datasets:

| Dataset | Description | Reference / Link |
|---------|-------------|------------------|
| Dataset A | Subset of SLIDL tutorial dataset | [GitHub – markowetzlab/slidl-tutorial](https://github.com/markowetzlab/slidl-tutorial) |
| Dataset B | Subset of the GrandQC test dataset | [Zenodo – Record 14039591](https://zenodo.org/records/14039591) |
| Dataset C (ours) | Dataset published with this study | To be published |

Please refer to the paper for the complete description of dataset preparation, inclusion criteria, and experimental settings.

## 📚 Citation

If you use this benchmark, code, or results in your research, please cite our paper:

```bibtex
@article{merta2026benchmarking,
  title   = {Benchmarking and Improvement of Artifact Segmentation Methods in H\&E-Stained Whole Slide Imaging},
  author  = {Merta, Julia and Mendelsohn, Daniel and Schoser, Benedikt and Polańska, Joanna and Marczyk, Michał},
  journal = {arXiv preprint arXiv:XXXX.XXXXX},
  year    = {2026},
  url     = {https://arxiv.org/abs/XXXX.XXXXX}
}
```

> **Benchmarking and Improvement of Artifact Segmentation Methods in H&E-Stained Whole Slide Imaging**  
> Julia Merta, Daniel Mendelsohn, Benedikt Schoser, Joanna Polańska, Michał Marczyk  
> *arXiv preprint*  
> [arXiv:XXXX.XXXXX](https://arxiv.org/abs/XXXX.XXXXX)

## 🔬 HistoKit

If you specifically use HistoKit, please also refer to its repository:

<a href="https://github.com/ZAEDPolSl/HistoKit/tree/main/src/histokit/">
  <img src="https://github.com/user-attachments/assets/30c97c3b-6dc7-4614-9792-ef4d166f11ca" alt="HistoKit" width="320" align="left">
</a>

<br clear="left">

## Contact

For questions regarding the benchmark or the paper, please contact:

**Julia Merta**
- Department of Data Science and Engineering
- Silesian University of Technology, Gliwice, Poland
- 📧 [julia.merta@polsl.pl](mailto:julia.merta@polsl.pl)

**Michał Marczyk**
- Department of Data Science and Engineering
- Silesian University of Technology, Gliwice, Poland
- 📧 [michal.marczyk@polsl.pl](mailto:michal.marczyk@polsl.pl)

## 🏛️ Department of Data Science and Engineering

**Silesian University of Technology**  
🎓 Faculty of Automatic Control, Electronics and Computer Science

[![Website](https://img.shields.io/badge/🌐_Website-polsl.pl-0057A8?style=for-the-badge)](https://www.polsl.pl/rau4/en/)
[![GitHub](https://img.shields.io/badge/GitHub-ZAEDPolSl-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ZAEDPolSl)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Follow_Us-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/company/department-of-data-science-and-engineering)

## 🧬 Founding

This work was partially funded by **CoMPaSS-NMD — Computational Models for New Patient Stratification Strategies of Neuromuscular Disorders**, a project funded by the **European Union under the Horizon Europe programme** (Grant Agreement No. **101080874**).

🔬 [**CoMPaSS-NMD Project — CORDIS**](https://cordis.europa.eu/project/id/101080874)

## 📜 License

Copyright (C) 2026 Julia Merta, Daniel Mendelsohn, Benedikt Schoser, Joanna Polańska, Michał Marczyk

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

