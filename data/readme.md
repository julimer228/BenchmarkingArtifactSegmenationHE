This folder contains the following files:
- `multiclass_results.csv` - results for multiclass artifact segmentation for GrandQC, HistoKit (Overlap 0.75, Constant Mode), and Patil et al.
- `processing_time.csv` - results of processing time for each method. For HistoKit overlaps 0.0, 0.25, 0.50, 0.75, 0.90 were tested, the final result is provided for HistoKit overlap 0.75.
- `binary_histokit_nopostprocessing.csv` - results for HistoKit for modes `constant` and `gaussian`, overlaps 0.0, 0.25, 0.50, 0.75, 0.90 and gaussian kernel std: 0.75, 1.25, 1.75, 2.25
- `binary_histokit_postprocessed.csv` - results for Histokit after the proposed postprocessing method.