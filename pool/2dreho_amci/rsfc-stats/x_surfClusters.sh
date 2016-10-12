ana_dir=/Users/YiwenZ/Documents/Data/MCI
scripts_dir=/opt/ccs
grpdir=${ana_dir}/group
fsaverage=fsaverage5

for sigCluster in preG postS rPCC
do
	for hemi in lh rh
	do
		glmdir=${grpdir}/groupanalysis/RSFC_stats/stats/${sigCluster}/${hemi}.RSFC.${sigCluster}
		## mci vs nc
        contrast=amci-nc
        bash ${scripts_dir}/ccs_07_grp_surfcluster.sh ${glmdir} ${contrast} ${hemi} ${fsaverage}
    done
done
