workdir=/Users/xinian.zuo/Downloads/2dReHo-MCI/rsfc-stats/rPCC
ccsdir=/Brain/CCS
hcpwbdir=${ccsdir}/extool/hcpworkbench
deformdir=${hcpwbdir}/resources/deform_maps

cd ${workdir} ;
if [ ! -d fs1mm ]
then
    mkdir -p fs1mm;
    mkdir -p fsLR
fi

for seed in amci nc
do
    for hemi in lh rh
    do
	if [ ! -f ${workdir}/fs1mm/${hemi}.mrsfc.${seed}.gii ]
	then
	    mri_surf2surf --srcsubject fsaverage5 --sval ${workdir}/${hemi}.mrsfc.${seed}.nii.gz --hemi ${hemi} --cortex --trgsubject fsaverage --tval ${workdir}/fs1mm/${hemi}.mrsfc.${seed}.nii.gz --noreshape --cortex
	    ${hcpwbdir}/bin_macosx64/wb_command -metric-convert -from-nifti ${workdir}/fs1mm/${hemi}.mrsfc.${seed}.nii.gz ${deformdir}/fs1mm/${hemi}.white.surf.gii ${workdir}/fs1mm/${hemi}.mrsfc.${seed}.gii
	fi
	if [ ${hemi} = "lh" ]
	then
	    /Brain/caret/bin_macosx64/caret_command -deformation-map-apply ${deformdir}/fs_L-to-fs_LR_164k.L.deform_map METRIC_AVERAGE_TILE ${workdir}/fs1mm/${hemi}.mrsfc.${seed}.gii ${workdir}/fsLR/${hemi}.mrsfc.${seed}.164k.gii
	    /Brain/caret/bin_macosx64/caret_command -deformation-map-apply ${deformdir}/fs_LR.164_to_32k.L.deform_map METRIC_AVERAGE_TILE ${workdir}/fsLR/${hemi}.mrsfc.${seed}.164k.gii ${workdir}/fsLR/${hemi}.mrsfc.${seed}.32k.gii
	fi
	if [ ${hemi} = "rh" ]
        then
            /Brain/caret/bin_macosx64/caret_command -deformation-map-apply ${deformdir}/fs_R-to-fs_LR_164k.R.deform_map METRIC_AVERAGE_TILE ${workdir}/fs1mm/${hemi}.mrsfc.${seed}.gii ${workdir}/fsLR/${hemi}.mrsfc.${seed}.164k.gii
            /Brain/caret/bin_macosx64/caret_command -deformation-map-apply ${deformdir}/fs_LR.164_to_32k.R.deform_map METRIC_AVERAGE_TILE ${workdir}/fsLR/${hemi}.mrsfc.${seed}.164k.gii ${workdir}/fsLR/${hemi}.mrsfc.${seed}.32k.gii
        fi
    done
done
