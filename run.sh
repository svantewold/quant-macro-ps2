echo "Running analysis"
echo "======================================"

echo "Solving capital tax rate grid..."
matlab -batch main
echo "======================================"

echo "Generating plots..."
Rscript src/plot_tax_mix.R
echo "======================================"

Rscript src/plot_welfare.R
echo "======================================"

Rscript src/plot_laffer_curve.R
echo "======================================"

echo "Analysis and plot generation finished."
