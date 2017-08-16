clear all;close all

subjID = input('Enter subject ID: ', 's');
load([subjID,'_TrialSeq']);
% CurrentTrial = input('Which run are you starting with? ');
%% Randomization
trial_num = size(Trial_template,1);
trial_num_base = sum(Trial_template(:,3) == 3);
trial_num_nobase = trial_num - trial_num_base;
if CurrentTrial == 1
     Trial_matrix(1:trial_num_base,2:3) = Trial_template(randperm(trial_num_base,trial_num_base),2:3);
     Trial_matrix((trial_num_base+1):trial_num,2:3) = Trial_template(randperm(trial_num_nobase,trial_num_nobase)+trial_num_base,2:3);
 %   Trial_matrix(1:trial_num,2:3) = Trial_template(randperm(trial_num,trial_num),2:3);
end;
%%
% computerName = 'Jeffrey';
if ~isempty(strfind(subjID, 'base'))
    params.demoForSubj = 'y';
else
    params.demoForSubj = 'n';
end;
params.difficulty = input('1:[-1~1]; 2:[-2~2]; 3:[-3~3]');
params.feedback = 0;
%params.demoForSubj = input('Subject demo (y/n)?','s')
%% Starting
% adaptation to spatial offsets with Glass patterns

Screen('Preference', 'SkipSyncTests', 1);
unix('networksetup -setairportpower en1 off');

stream = RandStream('mt19937ar','Seed',sum(100*clock));
RandStream.setGlobalStream(stream);
AssertOpenGL;
KbName('UnifyKeyNames')

% some user-defined parameters outside of params file
% disp('Note that stimulus duration here is longer!');
params.subjID = subjID;
params.runNumber = CurrentTrial;
params.controlCondition = Trial_matrix(CurrentTrial,2);
params.adaptConfig = Trial_matrix(CurrentTrial,3);
params.merConfig = 1; % vertical meridian

if params.adaptConfig < 3
    params.demoForSubj = 'n';
else
    params.demoForSubj = 'y';
end;

params.computer = 2;
% [~,comp_name] = system('hostname');
% if strcmp(comp_name(1:7) , computerName) %laptop
%     params.computer = 2;
% else
%     params.computer = 1;
% end


%%
basicMovieShiftVer4b;
CurrentTrial = CurrentTrial+1;
current_date = date;
save([subjID,'_TrialSeq'], 'CurrentTrial','Trial_matrix','Trial_template','current_date');

%% Ending 
Screen('CloseAll');
Priority(0);
save(params.filename,'params','display','history');
unix('networksetup -setairportpower en1 on');