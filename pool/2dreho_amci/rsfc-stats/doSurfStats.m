%% dir settings (may not usable for you and you have to change them...)
clear all; clc ;
ccs_dir = '/opt/ccs';
ccs_matlab = [ccs_dir '/matlab'];
ana_dir = '/Users/YiwenZ/Documents/Data/MCI';
sub_list = [ana_dir '/scripts/subjects.list'];
grpmask_dir = [ana_dir '/group/masks'];
rest_name = 'rest';

fs_home = '/Applications/freesurfer';
fsaverage = 'fsaverage5';

%% Adding paths to matlab
addpath(genpath(ccs_matlab)) %ccs matlab scripts
addpath(genpath([fs_home '/matlab'])) %freesurfer matlab scripts

%% FWE Cluster level correction: Quadratic
% loop metrics
sigCluster = {'preG', 'postS', 'rPCC' };
vwthresh = 0.01;
for mid=1:numel(sigCluster)
    sid = mid;
    %lh
    yfile = [ana_dir '/group/groupanalysis/RSFC_stats/smoothed_Data/'...
        sigCluster{mid} '/lh.zRSFC.' sigCluster{mid} '.sm6.nii.gz'];
    glmdir = [ana_dir '/group/groupanalysis/RSFC_stats/stats/'...
        sigCluster{mid} '/lh.RSFC.' sigCluster{mid}];
    sgn = 1;
    err = ccs_mri_surfrft_jlbr(yfile, glmdir, vwthresh, sgn);
    sgn = -1;
    err = ccs_mri_surfrft_jlbr(yfile, glmdir, vwthresh, sgn);
    %rh
    yfile = [ana_dir '/group/groupanalysis/RSFC_stats/smoothed_Data/'...
        sigCluster{mid} '/rh.zRSFC.' sigCluster{mid} '.sm6.nii.gz'];
    glmdir = [ana_dir '/group/groupanalysis/RSFC_stats/stats/'...
        sigCluster{mid} '/rh.RSFC.' sigCluster{mid}];
    sgn = 1;
    err = ccs_mri_surfrft_jlbr(yfile,glmdir,vwthresh,sgn);
    sgn = -1;
    err = ccs_mri_surfrft_jlbr(yfile,glmdir,vwthresh,sgn);
end

%% Triple tests
FWEthresh = 0.025/3; 
fig_dir = [ana_dir '/group/groupanalysis/RSFC_stats/stats/figures'];
contrasts = {'amci-nc'};
for mid=1:numel(sigCluster)
    for cid=1:numel(contrasts)
        %lh
        dirglmstats = [ana_dir '/group/groupanalysis/RSFC_stats/stats/'...
                sigCluster{mid} '/lh.RSFC.' sigCluster{mid} '/amci-nc'];
        fsig = [dirglmstats '/sig.mgh'];
        lh_sig = load_mgh(fsig); lh_tmpsig = zeros(size(lh_sig));
        fsig = [dirglmstats '/sig.cw.pos.mgh'];
        lh_cw_possig = load_mgh(fsig);
        idx = find(lh_cw_possig >= (-log10(FWEthresh)));
        if ~isempty(idx)
            lh_tmpsig(idx) = lh_sig(idx);
        end
        fsig = [dirglmstats '/sig.cw.neg.mgh'];
        lh_cw_negsig = load_mgh(fsig);
        idx = find(lh_cw_negsig <= log10(FWEthresh));
        if ~isempty(idx)
            lh_tmpsig(idx) = lh_sig(idx);
        end
        %rh
        dirglmstats = [ana_dir '/group/groupanalysis/RSFC_stats/stats/'...
                sigCluster{mid} '/rh.RSFC.' sigCluster{mid} '/amci-nc'];
        fsig = [dirglmstats '/sig.mgh'];
        rh_sig = load_mgh(fsig); rh_tmpsig = zeros(size(rh_sig));
        fsig = [dirglmstats '/sig.cw.pos.mgh'];
        rh_cw_possig = load_mgh(fsig);
        idx = find(rh_cw_possig >= (-log10(FWEthresh)));
        if ~isempty(idx)
            rh_tmpsig(idx) = rh_sig(idx);
        end
        fsig = [dirglmstats '/sig.cw.neg.mgh'];
        rh_cw_negsig = load_mgh(fsig);
        idx = find(rh_cw_negsig <= log10(FWEthresh));
        if ~isempty(idx)
            rh_tmpsig(idx) = rh_sig(idx);
        end
        %visualization
        if ~isempty(find([lh_tmpsig; rh_tmpsig])>0)
            %inflated
             ccs_hemiSurfStatView(lh_tmpsig, rh_tmpsig, [fs_home '/subjects/' fsaverage '/surf'], ...
                  'inflated', 'true', [fig_dir '/' contrasts{cid} '.' sigCluster{mid} '.inflated.lh.jpeg'], ...
                  [fig_dir '/' contrasts{cid} '.' sigCluster{mid} '.inflated.rh.jpeg'])
            ccs_SurfStatView([lh_tmpsig; rh_tmpsig], [fs_home '/subjects/' fsaverage '/surf'], ...
                'inflated', 'true', [fig_dir '/' contrasts{cid} '.' sigCluster{mid} '.inflated.jpeg'])
            %white
            ccs_SurfStatView([lh_tmpsig; rh_tmpsig], [fs_home '/subjects/' fsaverage '/surf'], ...
            'white', 'true', [fig_dir '/' contrasts{cid} '.' sigCluster{mid} '.white.jpeg'])
        end
    end
end
