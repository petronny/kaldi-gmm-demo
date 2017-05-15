#!/bin/bash

# Settings
num_gauss=2
data=data/data.ark
diag_gmm_dir=exp/diag_gmm

. ./path.sh
cmd="utils/run.pl"

# Clean up
echo Cleaning up
rm -rf data exp logs
mkdir data exp logs

# Generate data
# See https://cn.mathworks.com/help/stats/gmdistribution-class.html
echo Generating data
$cmd logs/generate-data.log python local/generate_data.py $data.txt
$cmd logs/convert-feats.log copy-feats ark,t:$data.txt ark:$data

# Train the GMM
echo Training GMM
$cmd logs/train_diag_gmm.log local/train_diag_gmm.sh \
	--nj 8 \
	--num-iters 5 \
	--initial-gauss-proportion 1 \
	--num-threads 8 \
	ark:$data \
	$num_gauss \
	$diag_gmm_dir

# Translate the GMM into readable format
echo Translating the GMM into readable format
$cmd logs/translate-diag-gmm.log gmm-global-copy \
	--binary=false \
	$diag_gmm_dir/final.dubm \
	$diag_gmm_dir/final.dubm.txt

# Calculate the likelihoods
echo Calculating the likelihoods
$cmd logs/calculate-likelihoods-by-frame.log gmm-global-get-frame-likes \
	$diag_gmm_dir/final.dubm \
	ark:$data \
	ark,t:exp/likelihoods-by-frame.ark
$cmd logs/calculate-likelihoods-by-sample.log gmm-global-get-frame-likes \
	--average \
	$diag_gmm_dir/final.dubm \
	ark:$data \
	ark,t:exp/likelihoods-by-sample.ark

# Print results
echo Success!
echo The GMM model is stored in $diag_gmm_dir
echo And the likelihoods are stored as exp/likelihoods-by-\{frame,sample\}.ark
