echo "Running analysis"
echo "--------------------------------------"

echo "Solving capital tax rate grid..."
matlab -batch main
echo "--------------------------------------"

echo "Generating plots..."
echo "--------------------------------------"

Rscript src/generate_plots.R
echo "--------------------------------------"

echo "Analysis and plot generation finished."
