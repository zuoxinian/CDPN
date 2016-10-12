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
metrics = {'reho', 'reho2'};
smooth = {'sm6', 'sm10'};
vwthresh = 0.01;
for mid=1:numel(metrics)
    sid = mid;
    %lh
    yfile = [ana_dir '/group/groupanalysis/4dmaps/lh.' metrics{mid} '.' smooth{sid} '.nii.gz'];
    glmdir = [ana_dir '/group/groupanalysis/stats/g4v2.' metrics{mid} '.lh'];
    sgn = 1;
    err = ccs_mri_surfrft_jlbr(yfile, glmdir, vwthresh, sgn);
    sgn = -1;
    err = ccs_mri_surfrft_jlbr(yfile, glmdir, vwthresh, sgn);
    %rh
    yfile = [ana_dir '/group/groupanalysis/4dmaps/rh.' metrics{mid} '.' smooth{sid} '.nii.gz'];
    glmdir = [ana_dir '/group/groupanalysis/stats/g4v2.' metrics{mid} '.rh'];
    sgn = 1;
    err = ccs_mri_surfrft_jlbr(yfile,glmdir,vwthresh,sgn);
    sgn = -1;
    err = ccs_mri_surfrft_jlbr(yfile,glmdir,vwthresh,sgn);
end

%% Triple tests
FWEthresh = 0.025; 
fig_dir = [ana_dir '/group/groupanalysis/figures'];
contrasts = {'amci-nc'};
for mid=1:numel(metrics)
    for cid=1:numel(contrasts)
        %lh
        dirglmstats = [ana_dir '/group/groupanalysis/stats/g4v2.' ...
            metrics{mid} '.lh/' contrasts{cid}];
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
        dirglmstats = [ana_dir '/group/groupanalysis/stats/g4v2.' ...
            metrics{mid} '.rh/' contrasts{cid}];
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
                'inflated', 'true', [fig_dir '/' contrasts{cid} '.' metrics{mid} '.inflated.lh.jpeg'], ...
                [fig_dir '/' contrasts{cid} '.' metrics{mid} '.inflated.rh.jpeg'])
            %white
            ccs_SurfStatView([lh_tmpsig; rh_tmpsig], [fs_home '/subjects/' fsaverage '/surf'], ...
                'white', 'true', [fig_dir '/' contrasts{cid} '.' metrics{mid} '.white.jpeg'])
        end
    end
end
