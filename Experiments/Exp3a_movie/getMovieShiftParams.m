function [mov params] = getMovieShiftParams(display,params)
%load movie and get parameters


%%%%%%%%% set parameters %%%%%%%%%%%%%%%%%%%%%%%%
params.fixLength = pix2angle(display,11);
params.redFix = 0;
params.useRedFix = 0;

params.merLabels = {'vert' 'horiz'};
params.rotLabels = {'regular' 'rot90'};
if params.merConfig == 1
    params.shiftDim = [2 4];%[2 4] or [1 3]
elseif params.merConfig == 2
    params.shiftDim = [1 3];
end
params.screenCapture = 0; % screen recording (for creating stimulus movie)
params.captureSize = 768;% px
params.scaleOrShift = 2; %type of distortion 1 for scale, 2 for shift
params.calcByArea = 0; %if distortion is scaling, scaling done by area(1) or height(0)
params.showDist = 0; % show numbers indicating size/direction of distortion
params.textMargin = 12; %px
params.destSize = 324; %384 half-size of final movie (pixels)

params.showOccluder = 1;
params.occluderWidth = 3.5;%*doubled  degrees across

if params.merConfig == 1%vertical
    params.occluderAng = 0;
else
    params.occluderAng = 90; %horizontal
    
end
params.respKeys = {'UpArrow' 'DownArrow';'LeftArrow' 'RightArrow'};
%for aperture
params.showApert = 1;
params.apertType = 2;%1 for standard gaussian, 2 for circular w/gaussian dropoff
params.apertPixels = params.destSize;%300;%384;%angle2pix(display, params.apertSize);%half-size of aperture
params.apertSize = pix2angle(display,params.apertPixels);
params.apertMaxL = 255; %maximum luminance/intensity
params.apertMinL = 100;%
%for gaussian version
params.apertGaussSD = 7; %*doubled SD of gaussian (deg)
%for circular version w/gaussian dropoff
params.apertRadius = 14;%*doubled deg
params.gaussDropSD = 2;%*doubled deg

% for targets
params.targetType = 2;% 1 for gaussian blob, 2 for vernier
params.targetW = 3;%*doubled  for vernier
params.targetH = .20;%*doubled %for vernier
params.targetSize = 8;%*doubled  %deg
if params.targetType == 1
    params.targetPixels = repmat(angle2pix(display,params.targetSize),1,2);
else
    params.targetPixels = [angle2pix(display,params.targetH)/2 angle2pix(display,params.targetW)/2];
end
params.targetGaussSD = 2;%*doubled
params.targetMaxL = 40;
params.targetSep = 10;%*doubled deg
params.targetOffset = 0;% from center
params.targetShifts = linspace(-.5,.5,6);
params.targetSides = [-1 1];
params.targetFrames = 5;
params.targetDur = params.targetFrames/display.refresh;
params.testConfigs = [1 2];

% for fixation targets
params.ftTimeJitter = [2 4]; %spacing
params.ftNextTime = params.ftTimeJitter(1)+(params.ftTimeJitter(2)-params.ftTimeJitter(1))*rand;
params.ftRespInt = 1;
params.ftRespRed = .5;
params.ftDur = .25;
params.ftIntensity= 50;

% for noise mask
params.noiseTexSize = params.destSize; %pix
params.noiseSq = 64;%# of squares on a side
params.noiseContrast = 1;
params.noiseMeanL = (255/5);
params.noiseApertured = 1;%1 for noise within aperture, 0 for no
params.nUniqueMasks = 20;

% load stuff related to the movie
params.movieDir = [cd(cd('../..')) '/Movies/DK'];
params.movieName = 'DK_full_extracted_motion_thr_0.2.mov';%

params.allCutFrames = [];
params.allChangeFrInd = 1:length(params.allCutFrames);
params.allCutFrames = params.allCutFrames(params.allChangeFrInd)-1;% checked, and you do in fact have to subtract 1 to get it to be the frame after the cut
params.customFps = 1;%set fps manually
params.fps = 24;%23.976023754029780;
params.timeTol = .005;% time tolerance
if strcmp(params.movieName(1:2),'MR') && params.runNumber==4
    params.offsetCorrection = 0.008379475801991;
else
    params.offsetCorrection = 0;
end
% params.movStillLims = [1 length(frameDiffs)];
mov = setupMovieShift(params,display); %load movie

params.startScale = 100;
params.startShift = 8;%px each - in original movie coordinates
%%%%% not used
if params.scaleOrShift == 1%not used
    params.scaleAmts = 80:5:120;
    params.shiftAmts = 0;
else
    params.scaleAmts = 95;%pct
    params.maxShift = ((100-params.scaleAmts)/100)*mov.h;%px;;% maximum total shift
    params.shiftAmts = linspace(-params.maxShift/6,params.maxShift/6,9);    % maximum possible is maxShift/2 on either end
end


if params.adaptConfig == 1
    params.shiftDirs = [-1 1];
elseif params.adaptConfig == 2
    params.shiftDirs = [1 -1];
elseif params.adaptConfig == 3
    params.shiftDirs = [0 0];
end
params.finalShift = 8;%px each - in original movie coordinates
params.shiftInc = 1;
params.shiftInterval = 300;%300; %apply distortion over first n seconds - not used (nChanges = 0)
params.nChanges = 0;%(params.finalShift/params.shiftInc)*2;

params.whichSide = Shuffle([ones(1,params.nChanges/2) 2*ones(1,params.nChanges/2)]);

params.possibleChangeFrames = params.allCutFrames(randperm(sum(params.allCutFrames/mov.fps<params.shiftInterval)));
params.selectedChangeFrames = sort(params.possibleChangeFrames(1:params.nChanges));
params.selectedChangeTimes = params.selectedChangeFrames/mov.fps;

if params.calcByArea== 1
    mov.dim1 = mov.h*sqrt(min(params.scaleAmts)/100);%
else
    mov.dim1 = mov.h*(min(params.scaleAmts)/100);%
end

mov.dim2 = mov.dim1;
mov.origDim1 = mov.dim1;
mov.origDim2 = mov.dim2;
mov.movieCenter = [mov.movieSize(1)/2 mov.movieSize(2)/2];

if ~isempty(strfind(params.demoForSubj,'y'))
    params.initAdapt = 0;
    params.topUpFreq = 40; %trials
else
    params.initAdapt = 540;%;%seconds
    params.topUpFreq = 12; %trials
end

params.topUpAdapt = 120;%sec

params.trialsPerCond = 8;
params.allTrials = Shuffle(repmat(1:length(params.targetShifts),1,params.trialsPerCond));
params.allTrials = [params.merConfig*ones(1,size(params.allTrials,2));2*ones(1,size(params.allTrials,2)); params.allTrials];
params.nTrials = size(params.allTrials,2);
params.maskOrder = Shuffle(repmat(1:params.nUniqueMasks,1,ceil(params.nTrials/params.nUniqueMasks)));
params.maskDur = .5;
params.ITI = .5;

pathname = pwd;
lastslash = find(pathname == '/',1,'last');
folder = pathname(lastslash+1:end);
params.filename = [params.subjID '_config' num2str(params.adaptConfig) '_r'  num2str(params.runNumber) '_pt'  num2str(params.whichPart) '_' params.merLabels{params.merConfig} '_'  params.rotLabels{params.rot90+1} '_' folder '_' datestr(now,'mmddyyyy') '_' datestr(now,'HHMM')];

params.captureFileName = ['ScreenCapture_' datestr(now,'mmddyyyy') '_' datestr(now,'HHMM') '.mov']; %if doing screen capture

end