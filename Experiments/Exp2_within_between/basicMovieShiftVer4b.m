% main stimulus script for adaptation with shifted moving lines

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

%% starting screen 1
display = StartingScreen_lines(params,display,tex);

% Playback loop
for trial = 1:params.nTrials
   [history,params] = doMovieShiftTrial(params,display,history,tex,trial);    
end

if params.screenCapture == 1
    Screen('FinalizeMovie', mov.movieRecPtr);
end