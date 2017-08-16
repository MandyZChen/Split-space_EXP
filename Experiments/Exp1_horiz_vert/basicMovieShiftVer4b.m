% main stimulus script for adaptation with shifted moving lines

clear all;close all

Screen('Preference', 'SkipSyncTests', 1);  % necessary for macbook air

% unix('networksetup -setairportpower en1 off'); % turn off wifi for testing

% Setting random seed
stream = RandStream('mt19937ar','Seed',sum(100*clock));
RandStream.setGlobalStream(stream);
AssertOpenGL;
KbName('UnifyKeyNames')

% some parameters outside of params file
params.subjID = input('Enter subject ID: ', 's');
params.runNumber = input('Enter run number: ');
params.merConfig = input('Vertical (1) or horizontal (2): ');%1 1 for vertical, 2 for horizontal
params.adaptConfig = input('Enter adaptation configuration (1 or 2 or 3): '); %adaptation condition
params.demoForSubj = input('Subject demo (y/n)?','s'); %skips the adaptation, goes straight to vernier
[~,comp_name] = system('hostname');
if strcmp(comp_name(1:7) ,'Whitney') %laptop
    params.computer = 2; % laptop
else
    params.computer = 1; % testing device
end

% get display settings/info
display = getMovieShiftDisplay;

% history struct for recording data
history = makeMovieShiftHistory;


if params.computer == 1
    Screen('Resolution', display.screenNumber, display.numPixels(1), display.numPixels(2),display.refresh); %testing computer
else
    Screen('Resolution', display.screenNumber, display.numPixels(1), display.numPixels(2)); %laptop
end

[display.w display.screenRect]=Screen('OpenWindow',display.screenNumber, display.black);
Screen('BlendFunction', display.w,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');

% get parameters
params = getMovieShiftParams(display,params);


% make textures
tex = makeMovieShiftTextures(display,params);

maxprio = MaxPriority(display.w);
Priority(maxprio);

%load CLUT for gamma correction
load CLUT_G30_1024x768_60Hz_111114.mat 
Screen('LoadNormalizedGammaTable', display.w, clut);


% starting screen
Screen(display.w, 'TextSize',24);
Screen(display.w,'DrawText','Press Space Bar to begin',50,50,255);
display.vbl = Screen('Flip', display.w);
HideCursor;
[keyIsDown,seconds,keyCode] = KbCheck(-1);
while ~keyCode(KbName('space'))
    [keyIsDown,~,keyCode] = KbCheck(-1);
end

WaitSecs(1);
Screen(display.w, 'TextSize',10);
% Playback loop
for trial = 1:params.nTrials
   [history,params] = doMovieShiftTrial(params,display,history,tex,trial);    
end

if params.screenCapture == 1
    Screen('FinalizeMovie', mov.movieRecPtr);
end
Screen('CloseAll');
Priority(0);
save(params.filename,'params','display','history');
unix('networksetup -setairportpower en1 on');