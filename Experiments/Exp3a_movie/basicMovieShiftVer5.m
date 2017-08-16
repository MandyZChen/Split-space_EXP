% adapatation to spatial offsets in movies

clear all;close all
Screen('Preference', 'SkipSyncTests', 1);
unix('networksetup -setairportpower en1 off');% turn off wifi for testing

stream = RandStream('mt19937ar','Seed',sum(100*clock));
RandStream.setGlobalStream(stream);

AssertOpenGL;
KbName('UnifyKeyNames')

% some parameters outside of params file
params.subjID = input('Enter subject ID: ', 's');
params.runNumber = input('Enter run number: ');
params.whichPart= input('Part 1 or 2?: '); %which movie file (counterbalanced w/adaptation conditions)
params.merConfig = input('Vertical (1) or horizontal (2): ');%1;%2;% 1 for vertical, 2 for horizontal
params.adaptConfig = input('Enter configuration (1 or 2 or 3): '); %adaptation configuration
params.rot90 = input('Rotate movie 90 degrees (1 = yes, 0 = no): ');%0; %rotate movie 90 degrees: 0 for no, 1 for yes

params.demoForSubj = input('Subject demo (y/n)?','s');
[~,comp_name] = system('hostname');
if strcmp(comp_name(1:7) ,'Jeffrey') %laptop
    params.computer = 2;
else
    params.computer = 1;
end

% get display information
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
[mov params] = getMovieShiftParams(display,params);
Screen(display.w, 'TextSize',24);

% make textures
tex = makeMovieShiftTextures(display,params);

% CLUT for gamma correction
load CLUT_G30_1024x768_60Hz_111114.mat %
Screen('LoadNormalizedGammaTable', display.w, clut,1);


%startup screen
Screen(display.w,'DrawText','Press Space Bar to begin',50,50,255);
Screen('Flip', display.w);
Screen(display.w, 'TextSize',10);
HideCursor;
[keyIsDown,seconds,keyCode] = KbCheck(-1);
while ~keyCode(KbName('space'))
    [keyIsDown,~,keyCode] = KbCheck(-1);
end
while keyIsDown
    keyIsDown = KbCheck(-1);
end

WaitSecs(1);

% Playback loop
for trial = 1:params.nTrials
   [history,mov,params] = doMovieShiftTrial(params,display,history,tex,mov,trial);    
end

if params.screenCapture == 1
    Screen('FinalizeMovie', mov.movieRecPtr);
end
Screen('CloseAll');
save(params.filename,'params','display','history','mov');
unix('networksetup -setairportpower en1 on');
%WaitSecs(20);