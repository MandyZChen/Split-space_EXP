clear all;close all

subjID = input('Enter subject ID: ', 's');
load([subjID,'_TrialSeq']);
% CurrentTrial = input('Which run are you starting with? ');

%% Randomization
if CurrentTrial == 1
    Trial_matrix(:,2:3) = Trial_template(randperm(12,12),2:3);
end;

params.demoForSubj = input('Subject demo (y/n)?','s');

%% Starting
% adaptation to spatial offsets with Glass patterns

Screen('Preference', 'SkipSyncTests', 1);
% unix('networksetup -setairportpower en1 off');

stream = RandStream('mt19937ar','Seed',sum(100*clock));
RandStream.setGlobalStream(stream);
AssertOpenGL;
KbName('UnifyKeyNames')

% some user-defined parameters outside of params file
% disp('Note that stimulus duration here is longer!');
params.subjID = subjID;
params.runNumber = CurrentTrial;

if Trial_matrix(CurrentTrial,2)==1
    params.symmetric = 1;
    params.randomRot = 0;
elseif Trial_matrix(CurrentTrial,2)==2
     params.symmetric = 1;
    params.randomRot = 1;
elseif Trial_matrix(CurrentTrial,2)==3
     params.symmetric = 0;
    params.randomRot = 0;  
end;

params.adaptConfig = Trial_matrix(CurrentTrial,3);
params.merConfig = 1; % vertical meridian

[~,comp_name] = system('hostname');
if strcmp(comp_name(1:7) ,'Whitney') %laptop
    params.computer = 2;
else
    params.computer = 1;
end


%%
MC_basicMovieShiftVer7a_Glass;
CurrentTrial = CurrentTrial+1;
current_date = date;
save([subjID,'_TrialSeq'], 'CurrentTrial','Trial_matrix','Trial_template','current_date');

%% Ending 
Screen('CloseAll');
Priority(0);
save(params.filename,'params','display','history');
unix('networksetup -setairportpower en1 on');