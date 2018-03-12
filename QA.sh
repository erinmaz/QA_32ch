#!/bin/bash

#Input: dicom directory from development node, containing two directories: 2 (BOLD) and 3 (epiRTmeasl)
#Normal use: go into study directory, use `pwd` as input (with the backticks).
#e.g., type: QA.sh `pwd`

in=$1
#hpf=$2
maskdir=/Users/pikelab/QAdata/masks
qadir=/Users/pikelab/QAdata

for f in `ls -d ${in}/*`
do
firstfile=`find ${f} -name *.dcm | head -1`
seriesname=`dicom_hinfo -tag 0008,103e -no_name $firstfile`
if [ "$seriesname" == "BOLD" ]; then
BOLDdir=$f
fi
if [ "$seriesname" == "epiRTmeasl" ]; then
epiRTmeasldir=$f
fi
done

#BOLDdir=2
#epiRTmeasldir=3

# Create NIFTI files
cd ${in}
dcm2niix ${BOLDdir}
mv ${BOLDdir}/*.nii.gz BOLD.nii.gz
cd ${epiRTmeasldir}
niidicom2 epiRTmeasl
cd ${in}
mv medata/* .
rm -r medata

fslview BOLD &
fslview epiRTmeasl.e01 &
fslview epiRTmeasl.e02 &

#100s highpass cutoff in FEAT
fslmaths BOLD -Tmean BOLD_Tmean
#fslmaths BOLD -bptf $hpf -1 -add BOLD_Tmean BOLD_bptf

# Get BOLD results
signalBOLD=`fslstats BOLD -k ${maskdir}/BOLDmask -M`
#signalBOLD_bptf=`fslstats BOLD_bptf -k ${maskdir}/BOLDmask -M`
noiseBOLD=`fslstats BOLD -k ${maskdir}/BOLDnoise -M`
#noiseBOLD_bptf=`fslstats BOLD_bptf -k ${maskdir}/BOLDnoise -M`
ghostBOLD=`fslstats BOLD -k ${maskdir}/BOLD_n2_ghost_final -M`
#ghostBOLD_bptf=`fslstats BOLD_bptf -k ${maskdir}/BOLD_n2_ghost_final -M`

fslmaths BOLD -Tstd BOLD_Tstd
fslmaths BOLD_Tmean.nii.gz -div BOLD_Tstd.nii.gz BOLD_Tsnr
#fslmaths BOLD_bptf -Tmean BOLD_bptf_Tmean
#fslmaths BOLD_bptf -Tstd BOLD_bptf_Tstd
#fslmaths BOLD_bptf_Tmean.nii.gz -div BOLD_bptf_Tstd.nii.gz BOLD_bptf_Tsnr
tSNRBOLD=`fslstats BOLD_Tsnr -k ${maskdir}/BOLDmask -M`
#tSNRBOLD_bptf=`fslstats BOLD_bptf_Tsnr -k ${maskdir}/BOLDmask -M`
#fslview BOLD_Tsnr BOLD_bptf_Tsnr &
fslview BOLD_Tsnr &
echo $in,$signalBOLD,$noiseBOLD,$ghostBOLD,$tSNRBOLD >> ${qadir}/QA_BOLD.txt
#echo $in,$signalBOLD_bptf,$noiseBOLD_bptf,$ghostBOLD_bptf,$tSNRBOLD_bptf >> ${qadir}/QA_BOLD_bptf.txt

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