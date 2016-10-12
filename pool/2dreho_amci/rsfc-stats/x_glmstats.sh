ana_dir=/Users/YiwenZ/Documents/Data/MCI

for sigCluster in preG postS rPCC
do
    mkdir ./${sigCluster}
    for hemi in lh rh
	do
        mri_glmfit \
        --glmdir ${sigCluster}/${hemi}.RSFC.${sigCluster} \
        --y ${ana_dir}/group/groupanalysis/RSFC_stats/smoothed_Data/${sigCluster}/${hemi}.zRSFC.${sigCluster}.sm6.nii.gz  \
        --fsgd g4v2.fsgd \
        --C amci-nc.mtx \
        --surf fsaverage5 ${hemi} \
        --mask ${ana_dir}/group/masks/${hemi}.reho.MCI.nii.gz \
        --cortex
	done
done
