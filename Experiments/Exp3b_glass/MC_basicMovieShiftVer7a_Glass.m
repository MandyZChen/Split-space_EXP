
%%
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

% get stimulus parameters
params = MC_getMovieShiftParams(display,params);

% make textures
tex = makeMovieShiftTextures(display,params);

maxprio = MaxPriority(display.w);
Priority(maxprio);


%load CLUT for gamma correction
load CLUT_G30_1024x768_60Hz_040915_Brightness20_Contrast80.mat
Screen('LoadNormalizedGammaTable', display.w, clut);

% startup screen
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
