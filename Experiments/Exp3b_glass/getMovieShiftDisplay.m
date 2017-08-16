function display = getMovieShiftDisplay


display.screens = Screen('Screens');
display.screenNumber = max(display.screens);
Screen('Preference', 'SuppressAllWarnings', 0);
Screen('Preference','SkipSyncTests',0);

display.white = WhiteIndex(display.screenNumber);
display.black = BlackIndex(display.screenNumber);
display.gray = round((display.white+display.black)/2);

%%%%%%%%% set up display %%%%%%%%%%%%%%%%%%%%%%%
display.numPixels = [1024 768];%[1680 1050];%[1024 768];
display.dimensions = [39 29];% G30 monitor[35.75 26]; %cm %for 60Hz refresh & 1024 x 768 %FOR NEW MONITOR
display.distance = 28.5; %cm of viewing distance
display.cmapDepth = 8;

display.refresh = 60;
display.pixelSize = mean(display.dimensions./display.numPixels);

display.center = display.numPixels/2;


end