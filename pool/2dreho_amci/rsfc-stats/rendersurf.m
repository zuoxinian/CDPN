%% Setting basic variables
clear all; clc ;
ccs_dir = '/Brain/CCS';
ccs_vistool = [ccs_dir '/vistool'];
ccs_matlab = [ccs_dir '/matlab'];
cifti_matlab = [ccs_dir '/extool/cifti'];
atlas_dir = [ccs_dir '/extool/hcpworkbench/resources/32k_ConteAtlas_v2'];
ana_dir = '/Users/xinian.zuo/Downloads/2dReHo-MCI/rsfc-stats/rPCC';
fs_home = '/Brain/freesurfer';
fsaverage = 'fsaverage5';

%% Add paths to MATLAB
%Set up the path to matlab function in Freesurfer release
addpath(genpath(ccs_matlab)) %ccs matlab scripts
addpath(genpath(ccs_vistool)) %ccs matlab scripts
addpath(genpath(cifti_matlab)) %cifti paths
addpath(genpath([fs_home '/matlab'])) %freesurfer matlab scripts

%% Setting up for Visualization
fcolor = [ccs_dir '/vistool/hotcolors.tif'];
cmap_hot = ccs_mkcolormap(fcolor);
fcolor = [ccs_dir '/vistool/coldcolors.tif'];
cmap_cold = ccs_mkcolormap(fcolor);
cmap_bidirection = [cmap_cold(end:-2:1,:);cmap_hot(1:2:end,:)];
cmap_bidirection(128:129,:) = 0.5;
%afni Y2C colormap
fcolor = [ccs_dir '/vistool/fimages/AFNI_Y2C.tif'];
cmap_afniy2c = ccs_mkcolormap(fcolor);
%caret single direction
fcolor = [ccs_dir '/vistool/fimages/caret_sdirection.tif'];
cmap_caret = ccs_mkcolormap(fcolor);
cmap_icc = cmap_caret; cmap_icc(1,:) = 0.5;
%caret bi direction
fcolor = [ccs_dir '/vistool/fimages/caret_bdirection.tif'];
cmap_caret = ccs_mkcolormap(fcolor);
cmap_corr = cmap_caret; cmap_corr(127:129,:) = 0.5;
%Left Hemisphere
fSURF = [atlas_dir '/Conte69.L.very_inflated.32k_fs_LR.surf.gii'];
lh_inflated = gifti(fSURF);
%make Conte69 surface structure
surfConte69_inflated_lh.tri = lh_inflated.faces;
surfConte69_inflated_lh.coord = lh_inflated.vertices'; 
nVertices_lh = size(lh_inflated.vertices,1);
%Right Hemisphere
fSURF = [atlas_dir '/Conte69.R.very_inflated.32k_fs_LR.surf.gii'];
rh_inflated = gifti(fSURF);
%make Conte69 surface structure
surfConte69_inflated_rh.tri = rh_inflated.faces;
surfConte69_inflated_rh.coord = rh_inflated.vertices'; 
nVertices_rh = size(rh_inflated.vertices,1);

%% Load network contour information and test
load([ccs_dir '/vistool/conte32k_yeo7networks_contour_lh.mat']);
load([ccs_dir '/vistool/conte32k_yeo7networks_contour_rh.mat']);

%% Figure 1
cmin = 2; FWEthresh = 0.025/3; 
cmincw = -log10(FWEthresh); maps = {'amci-nc'};
for mapid=1:numel(maps);
    maps{mapid}
    %lh
    fMAP = [ana_dir '/fsLR/lh.' maps{mapid} '.sig.32k.gii'];
    lh_map = gifti(fMAP); 
    sigMap_lh = double(lh_map.cdata);
    corrMap_lh = zeros(size(sigMap_lh));
    fMAP = [ana_dir '/fsLR/lh.' maps{mapid} '.sig.cw.pos.32k.gii'];
    lh_map = gifti(fMAP); 
    sigposMap_lh = double(lh_map.cdata);
    idx = find(sigposMap_lh >= cmincw);
    if ~isempty(idx)
        corrMap_lh(idx) = sigMap_lh(idx);
    end
    fMAP = [ana_dir '/fsLR/lh.' maps{mapid} '.sig.cw.neg.32k.gii'];
    lh_map = gifti(fMAP); 
    signegMap_lh = double(lh_map.cdata);
    idx = find(signegMap_lh <= -cmincw);
    if ~isempty(idx)
        corrMap_lh(idx) = sigMap_lh(idx);
    end
    corrMap_lh((rsncSurf_lh==1)) = 0.15*cmin;
    %rh
    fMAP = [ana_dir '/fsLR/rh.' maps{mapid} '.sig.32k.gii'];
    rh_map = gifti(fMAP); 
    sigMap_rh = double(rh_map.cdata);
    corrMap_rh = zeros(size(sigMap_rh));
    fMAP = [ana_dir '/fsLR/rh.' maps{mapid} '.sig.cw.pos.32k.gii'];
    rh_map = gifti(fMAP); 
    sigposMap_rh = double(rh_map.cdata);
    idx = find(sigposMap_rh >= cmincw);
    if ~isempty(idx)
        corrMap_rh(idx) = sigMap_rh(idx);
    end
    fMAP = [ana_dir '/fsLR/rh.' maps{mapid} '.sig.cw.neg.32k.gii'];
    rh_map = gifti(fMAP); 
    signegMap_rh = double(rh_map.cdata);
    idx = find(signegMap_rh <= -cmincw);
    if ~isempty(idx)
        corrMap_rh(idx) = sigMap_rh(idx);
    end
    corrMap_rh((rsncSurf_rh==1)) = 0.15*cmin;
    %visualize
    corrMap = [corrMap_lh; corrMap_rh];
    cmax = max(abs(corrMap));
    cint = round(128*cmin/cmax);
    cmapcut_side = cmap_afniy2c;
    cmapcut_side((128-cint):(128+cint),:) = 0.5;
    cmapcut_side(round(128-0.20*cint):round(128-0.10*cint),:) = 0.25;
    cmapcut_side(round(128+0.10*cint):round(128+0.20*cint),:) = 0.25;
    idx_cold = 1:(128-cint-1); 
    idx_resamp_cold = round(linspace(1,256,numel(idx_cold)));
    cmapcut_side(idx_cold,:) = cmap_cold(idx_resamp_cold(end:-1:1),:);
    idx_hot = (128+cint+1):256; 
    idx_resamp_hot = round(linspace(1,256,numel(idx_hot)));
    cmapcut_side(idx_hot,:) = cmap_hot(idx_resamp_hot,:);
    %lh
    figure('Units', 'pixel', 'Position', [100 100 800 800]); axis off
    SurfStatView(corrMap_lh, surfConte69_inflated_lh, ' ', 'white', 'true'); 
    colormap(cmapcut_side); SurfStatColLim([-cmax cmax]);
    set(gcf, 'PaperPositionMode', 'auto');
    figout = [ana_dir '/figures/' maps{mapid} '.lh.png'];
    print('-dpng', '-r300', figout); close
    %rh
    figure('Units', 'pixel', 'Position', [100 100 800 800]); axis off
    SurfStatView(corrMap_rh, surfConte69_inflated_rh, ' ', 'white', 'true'); 
    colormap(cmapcut_side); SurfStatColLim([-cmax cmax]);
    set(gcf, 'PaperPositionMode', 'auto');
    figout = [ana_dir '/figures/' maps{mapid} '.rh.png'];
    print('-dpng', '-r300', figout); close
end

%% Figure 1: average
fmask = [ana_dir '/lh.RSFC.rPCC/mask.mgh'];%lh
tmpmaskvol = load_mgh(fmask);
freho = [ana_dir '/lh.zRSFC.rPCC.sm6.nii.gz'];
tmphdr = load_nifti(freho); rehovol = squeeze(tmphdr.vol);
fsample = ['/Users/xinian.zuo/Downloads/dnb_healthybrain/' ...
    'Figures/Figure1/fs5/lh.dnb.bin13.627.fsaverage5.nii.gz'];
samplehdr = load_nifti(fsample); samplehdr.datatype = 16;
rehovol(tmpmaskvol==0,:) = 0;
%nc
samplehdr.vol = mean(rehovol(:,1:39),2);
fmreho = [ana_dir '/lh.mrsfc.nc.nii.gz'];
err1 = save_nifti(samplehdr, fmreho);
%mci
samplehdr.vol = mean(rehovol(:,40:end),2);
fmreho = [ana_dir '/lh.mrsfc.amci.nii.gz'];
err2 = save_nifti(samplehdr, fmreho);

fmask = [ana_dir '/rh.RSFC.rPCC/mask.mgh'];%rh
tmpmaskvol = load_mgh(fmask);
freho = [ana_dir '/rh.zRSFC.rPCC.sm6.nii.gz'];
tmphdr = load_nifti(freho); rehovol = squeeze(tmphdr.vol);
fsample = ['/Users/xinian.zuo/Downloads/dnb_healthybrain/' ...
    'Figures/Figure1/fs5/rh.dnb.bin13.627.fsaverage5.nii.gz'];
samplehdr = load_nifti(fsample); samplehdr.datatype = 16;
rehovol(tmpmaskvol==0,:) = 0;
%nc
samplehdr.vol = mean(rehovol(:,1:39),2);
fmreho = [ana_dir '/rh.mrsfc.nc.nii.gz'];
err3 = save_nifti(samplehdr, fmreho);
%mci
samplehdr.vol = mean(rehovol(:,40:end),2);
fmreho = [ana_dir '/rh.mrsfc.amci.nii.gz'];
err4 = save_nifti(samplehdr, fmreho);

%% Figure 1: rendering mean maps
fig_dir = [ana_dir '/figures'];
maps = {'amci', 'nc'};
for mapid=1:numel(maps);
    maps{mapid}
    %lh
    fMAP = [ana_dir '/fsLR/lh.mrsfc.' maps{mapid} '.32k.gii'];
    lh_map = gifti(fMAP); corrMap_lh = double(lh_map.cdata);
    %rh
    fMAP = [ana_dir '/fsLR/rh.mrsfc.' maps{mapid} '.32k.gii'];
    rh_map = gifti(fMAP); corrMap_rh = double(rh_map.cdata);
    %bh
    corrMap = [corrMap_lh; corrMap_rh]; cmax = max(corrMap);
    %render
    figure('Units', 'pixel', 'Position', [100 100 800 800]); axis off
    SurfStatView(tanh(corrMap_lh), surfConte69_inflated_lh, ' ', 'white', 'true'); 
    colormap(cmap_icc); SurfStatColLim([0 1]);
    set(gcf, 'PaperPositionMode', 'auto');
    figout = [ana_dir '/figures/' maps{mapid} '.mrsfc.lh.png'];
    print('-dpng', '-r300', figout); close
    figure('Units', 'pixel', 'Position', [100 100 800 800]); axis off
    SurfStatView(tanh(corrMap_rh), surfConte69_inflated_rh, ' ', 'white', 'true'); 
    colormap(cmap_icc); SurfStatColLim([0 1]);
    set(gcf, 'PaperPositionMode', 'auto');
    figout = [ana_dir '/figures/' maps{mapid} '.mrsfc.rh.png'];
    print('-dpng', '-r300', figout); close
end
