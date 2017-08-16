clear all;close all

% load([subjID,'_TrialSeq']);
% CurrentTrial = input('Which run are you starting with? ');
%% Randomization
% trial_num = size(Trial_template,1);
% trial_num_base = sum(Trial_template(:,3) == 3);
% trial_num_nobase = trial_num - trial_num_base;
% if CurrentTrial == 1
%      Trial_matrix(1:trial_num_base,2:3) = Trial_template(randperm(trial_num_base,trial_num_base),2:3);
%      Trial_matrix((trial_num_base+1):trial_num,2:3) = Trial_template(randperm(trial_num_nobase,trial_num_nobase)+trial_num_base,2:3);
%  %   Trial_matrix(1:trial_num,2:3) = Trial_template(randperm(trial_num,trial_num),2:3);
% end;
% computerName = 'Jeffrey';
params.demoForSubj = 'y';
params.subjID = input('Enter subject ID: ', 's');
params.difficulty = input('1:[-1~1]; 2:[-2~2]; 3:[-3~3]');
params.runNumber = input('Which run?');
params.controlCondition = input('Which spatial locations? 1:up, 2:down, 3:left, 4:right');
params.feedback = 1;


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
params.adaptConfig = 3; % no offset
params.merConfig = 1; % vertical meridian
params.computer = 1;
%%
basicMovieShiftVer4b;

%% Calculate percentage correct

percentageCorrect = sum(history.correct == 1)/ sum(history.correct ~= 0);
fprintf(['Your percentage correct is %.2f\n'],percentageCorrect);

%% Ending 
Screen('CloseAll');
Priority(0);
save(params.filename,'params','display','history');
unix('networksetup -setairportpower en1 on');