function [FILES_OUT] = SPARK_fMRI_pupillometry(FILES_IN,OPT)
% Perform a four-step analysis: 
% (STEP 1) Pupillometry processing
% (STEP 2) State stratification of fMRI data using pupillometry
% (STEP 3) Bootstrap resampling of state-stratified fMRI data
% (STEP 4) Sparse dictionary learning of resampled data
%
% SYNTAX:
% [FILES_OUT] = SPARK_fMRI_pupillometry(FILES_IN,FILES_OUT,OPT)
% 
% REQUIREMENTS:
%    SPM8 or SPM12
%       addpath(genpath('/spm12'))
%    SPARK
%       addpath(genpath('SPARK'))
% _________________________________________________________________________
% INPUTS
%
% FILES_IN  
%   (structure) with the following fields :
%
%   FMRI
%      (array) a (time x space) fMRI data matrix.
%   PUPILLOMETRY
%      (array) a (time x 1) pupillometry vector.
%
% OPT
%   (structure) with the following fields :
%
%   PUPILRANGE
%      ([MIN MAX], maximum 100, default [0 20]) (% from the top) for pupil size
%
%
% OUTPUTS
%
% FILES_OUT
%   (structure) with the following fields :
%
%   TDATA
%      (array) a (reduced time x space) state-stratified fMRI data
%   STATETP
%      (array) a vector of time-point stamps selected to define a state
%   TSERIES_BOOT
%      (array) a (reduced time x space) state-stratified and resampled fMRI data
%   DICTIONARY
%      (array) a (reduced time x atom) matrix
%   OUTPUT
%      (structure) with the following fields :
%         OPT_K
%            (array) a (1 x space) vector, k-hubness 
%         TOTALERR
%            (array) a (1 x (iteration - 1) ) vector, model error
%         COEFMATRIX
%            (array) a (atom x space) matrix
%   PARAM
%      (structure) parameters of sparse dictionary learning



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tseries      =  FILES_IN.fMRI; % Preprocessed fMRI data (time by space)
pupilarea    =  FILES_IN.pupillometry; % Blick-corrected, low-pass filtered, resampled pupil timecourse
pthU         =  OPT.pupilrange(2);
pthL         =  OPT.pupilrange(1);


%---------------------------------------------------------
% (STEP 1) Pupillometry processing
%---------------------------------------------------------

% Z transform pupil area
pupilarea_z=zscore(pupilarea);

% Convolve pupil timecourse with canonical HRF (mixture of two Gamma functions)
xBF.dt = 1; 
xBF.name = 'hrf'; 
bf = spm_get_bf(xBF);
U.u = pupilarea_z;
U.name = {'pupilarea'};
pupilarea_z_hrf = spm_Volterra(U, bf.bf);
Pseries=pupilarea_z_hrf;

% Find ranked pupil size-based thresholds for pupil timecourse
Pseries_sort=sort(Pseries,'descend');
state_L=Pseries_sort(length(Pseries)*pthU/100);
if pthL == 0
    state_tp=find(Pseries >= state_L);
else
    state_U=Pseries_sort(length(Pseries)*pthL/100);
    state_tp= find(Pseries >= state_L & Pseries < state_U);
end






%---------------------------------------------------------
% (STEP 2) State stratification of fMRI data using pupillometry
%---------------------------------------------------------

Tdata=Tseries(state_tp,:); 





%---------------------------------------------------------
% (STEP 3) Bootstrap resampling of state-stratified fMRI data
%---------------------------------------------------------

T=size(Tdata,1);
fprintf(['bootstrap resampling \n']);
Tseries_boot=[];
flag=1;
while flag
    block_length= randi([ceil(sqrt(size(Tdata,1))) 2*ceil(sqrt(size(Tdata,1)))],1);
    startpoint= randi([1 T-block_length],1);
    tp=linspace(startpoint,startpoint+block_length-1,block_length)';
    block_tseries=Tdata(tp,:);
    Tseries_boot=vertcat(Tseries_boot,block_tseries);
    fprintf(['Concatenating a block(length=' num2str(block_length) ').\n'])
    if size(Tseries_boot,1) > T
        flag=0;
    end
end
Tseries_boot= Tseries_boot(1:T,:);
clear flag block_length startpoint tp






%---------------------------------------------------------
% (STEP 4) Sparse dictionary learning of resampled data
%---------------------------------------------------------

% Parameter Initialization
for mdl_iter=1%:10
    [MDL_scale(:,:,mdl_iter),opt.param{mdl_iter},grad_fig(:,:,mdl_iter)] = ...
        regionlevel_param_estimation_fMRI(Tseries_boot,mdl_iter);
    initklist(mdl_iter)=opt.param{mdl_iter}.initk;
    netscalelist(mdl_iter)=opt.param{mdl_iter}.net_scale;
end;


% Sparse Dictionary Learning 
param.L                           = [];
param.K                           = final_netscale;
param.kmax                        = round(final_netscale/2);
param.initk                       = final_initk;
param.numIteration                = 30;
param.errorFlag                   = 0;
param.preserveDCAtom              = 0;
param.InitializationMethod        = 'GivenMatrix';
param.SparsecodingMethod          = 'Thresholding';
param.displayProgress             = 1;
rperm=randperm(size(Tseries_boot,2));
initD=Tseries_boot(:,rperm(1:param.K));
param.initialDictionary=initD; clear initD rperm
fprintf(['A varient of K-SVD on ' num2str(boot_n) '-th bootstrap data: N=' ...
    num2str(final_netscale) ', initk=' num2str(final_initk) '.\n'])
fprintf('\n')
[Dictionary, output]       = spark_vKSVD(Tseries_boot, param);





%% Save results
FILES_OUT.Tdata        = Tdata;
FILES_OUT.statetp      = statetp;
FILES_OUT.Tseries_boot = Tseries_boot;
FILES_OUT.Dictionary   = Dictionary;
FILES_OUT.output       = output;
FILES_OUT.param        = param;






fprintf('%20s\n','...Completed')


