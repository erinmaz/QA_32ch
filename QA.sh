#!/bin/bash

#Input: dicom directory from development node, containing two directories: 2 (BOLD) and 3 (epiRTmeasl)
#Normal use: go into study directory, use `pwd` as input (with the backticks).
#e.g., type: QA.sh `pwd`

in=$1
maskdir=/Users/pikelab/QAdata/masks
qadir=/Users/pikelab/QAdata
BOLDdir=2
epiRTmeasldir=3

# Create NIFTI files
cd ${in}
dcm2niix ${BOLDdir}
mv ${BOLDdir}/*.nii.gz BOLD.nii.gz
cd ${in}/${epiRTmeasldir}
niidicom2 epiRTmeasl
cd ${in}
mv medata/* .
rm -r medata

fslview BOLD &
fslview epiRTmeasl.e01 &
fslview epiRTmeasl.e02 &

# Get BOLD results
signalBOLD=`fslstats BOLD -k ${maskdir}/BOLDmask -M`
noiseBOLD=`fslstats BOLD -k ${maskdir}/BOLDnoise -M`
ghostBOLD=`fslstats BOLD -k ${maskdir}/BOLD_n2_ghost_final -M`
fslmaths BOLD -Tmean BOLD_Tmean
fslmaths BOLD -Tstd BOLD_Tstd
fslmaths BOLD_Tmean.nii.gz -div BOLD_Tstd.nii.gz BOLD_Tsnr
tSNRBOLD=`fslstats BOLD_Tsnr -k ${maskdir}/BOLDmask -M`
fslview BOLD_Tsnr &
echo $in,$signalBOLD,$noiseBOLD,$ghostBOLD,$tSNRBOLD >> ${qadir}/QA_BOLD.txt

# Get epiRTmeasl results
signalepiRTmeasl=`fslstats epiRTmeasl.e01 -k ${maskdir}/epiRTmeaslmask -M`
noiseepiRTmeasl=`fslstats epiRTmeasl.e01 -k ${maskdir}/epiRTmeaslnoise -M`
ghostepiRTmeasl=`fslstats epiRTmeasl.e01 -k ${maskdir}/epiRTmeasl_n2_ghost_final -M`
fslmaths epiRTmeasl.e01 -Tmean epiRTmeasl.e01_Tmean
fslmaths epiRTmeasl.e01 -Tstd epiRTmeasl.e01_Tstd
fslmaths epiRTmeasl.e01_Tmean.nii.gz -div epiRTmeasl.e01_Tstd.nii.gz epiRTmeasl.e01_Tsnr
tSNRepiRTmeasl=`fslstats epiRTmeasl.e01_Tsnr -k ${maskdir}/epiRTmeaslmask -M`
fslview epiRTmeasl.e01_Tsnr &
echo $in,$signalepiRTmeasl,$noiseepiRTmeasl,$ghostepiRTmeasl,$tSNRepiRTmeasl >> ${qadir}/QA_epiRTmeasl.e01.txt

signalepiRTmeasl=`fslstats epiRTmeasl.e02 -k ${maskdir}/epiRTmeaslmask -M`
noiseepiRTmeasl=`fslstats epiRTmeasl.e02 -k ${maskdir}/epiRTmeaslnoise -M`
ghostepiRTmeasl=`fslstats epiRTmeasl.e02 -k ${maskdir}/epiRTmeasl_n2_ghost_final -M`
fslmaths epiRTmeasl.e02 -Tmean epiRTmeasl.e02_Tmean
fslmaths epiRTmeasl.e02 -Tstd epiRTmeasl.e02_Tstd
fslmaths epiRTmeasl.e02_Tmean.nii.gz -div epiRTmeasl.e02_Tstd.nii.gz epiRTmeasl.e02_Tsnr
tSNRepiRTmeasl=`fslstats epiRTmeasl.e02_Tsnr -k ${maskdir}/epiRTmeaslmask -M`
fslview epiRTmeasl.e02_Tsnr
echo $in,$signalepiRTmeasl,$noiseepiRTmeasl,$ghostepiRTmeasl,$tSNRepiRTmeasl >> ${qadir}/QA_epiRTmeasl.e02.txt