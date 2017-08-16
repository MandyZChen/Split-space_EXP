function params = getMovieShiftParams(display,params)
%load movie and get parameters



%% New changes
eccen_num = angle2pix(display, 12);
eccen_num_up = angle2pix(display, 10);
params.eccentricity = [eccen_num_up,eccen_num_up,eccen_num,eccen_num];

%% %%%%%%% set parameters %%%%%%%%%%%%%%%%%%%%%%%%

params.LocIndex = 0;
params.fixLength = pix2angle(display,11);
params.redFix = 0;
params.useRedFix = 0;

params.merLabels = {'vert' 'horiz'};
params.rotLabels = {'regular' 'rot90'};
params.controlLabels ={'upper' 'lower' 'left' 'right'};
params.saveLabels ={'up' 'down' 'left' 'right'};

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
params.destSize = 384 %384; %384 half-size of final movie (pixels)

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
params.apertPixels = display.center(1);%params.destSize;%300;%384;%angle2pix(display, params.apertSize);%half-size of aperture
params.noiseSize = params.destSize;
params.apertSize = pix2angle(display,params.apertPixels);
params.apertMaxL = 255; %maximum luminance/intensity
params.apertMinL = 100;%128;%0;%190;%180;%180;%128;
%for gaussian version
params.apertGaussSD = 9;%9; %*doubled SD of gaussian (deg)
%for circular version w/gaussian dropoff
params.apertRadius = 17;%18;%*doubled deg
params.gaussDropSD = 3;%3;%*doubled deg

params.lineCenterBound = angle2pix(display,params.apertRadius+params.gaussDropSD*3);

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
params.targetSep = 7;%*doubled deg
params.targetOffset = 0;%5;%0;%5;% from center
% if params.controlCondition == 1
%     params.targetShifts = linspace(-1,1,6);
% else
%     params.targetShifts = linspace(-.5,.5,6);
% end

if params.difficulty == 1
    params.targetShifts = linspace(-.5,.5,6);
elseif params.difficulty == 2
     params.targetShifts = linspace(-1,1,6);
elseif params.difficulty == 3
     params.targetShifts = linspace(-1.5,1.5,6);
end;

params.targetSides = [-1 1];%left, right
params.targetFrames = 8;%duration
params.targetDur = params.targetFrames/display.refresh;
params.testConfigs = [1 2];

% for oriented targets (presented during adaptation -- not used in this version)
if params.merConfig == 1
    params.otAngles = 155:5:205;
else
    params.otAngles = (155:5:205)-90;
end
params.otColor = 80;
params.otJitter = .5;%deg in each direction +/- 3
params.otLength = 30;

%%% parameters for random lines
params.nLines = 25;
params.lineWidth = pix2angle(display,10);
params.lengthRange = [30 45];%shortest and longest lengths (deg)
params.lineVel=4;%px
params.orientBounds = [90 270; 180 360];

% for noise mask
params.noiseTexSize = params.destSize; %pix
params.noiseSq = 64;%# of squares on a side
params.noiseContrast = 1;
params.noiseMeanL = (255/5);
params.noiseApertured = 1;%1 for noise within aperture, 0 for no
params.nUniqueMasks = 20;

params.startScale = 100;
params.startShift = 0;

% for target detection task;
params.ftTimeJitter = [2 4]; %spacing
params.ftNextTime = params.ftTimeJitter(1)+(params.ftTimeJitter(2)-params.ftTimeJitter(1))*rand;
params.ftRespInt = 1;
params.ftRespRed = .5;
params.ftIntensity = 50;
params.ftDur = .25;

params.shiftDirs = [-1 1 0];

%initial adaptation
if ~isempty(strfind(params.demoForSubj,'y'))
    params.initAdapt = 0;
else
    params.initAdapt = 480;%
end

if params.adaptConfig == 3
    params.topUpAdapt=0;
else
    params.topUpAdapt = 60;%seconds
end;
params.topUpFreq = 12; %trials

params.shiftAmount = 24;  % 24 (Anna)
params.currShift = params.shiftDirs(params.adaptConfig)*params.shiftAmount;%0;%starting shift
params.finalShift = params.shiftAmount;%;%px TOTAL

% the following 5 not used in this code
params.shiftInc = 1; %increments for introducing distortion
params.shiftInterval = 300;%300; %apply distortion over first n seconds
params.nChanges = (params.finalShift/params.shiftInc);
params.minSep = 5;%separation between changes in seconds
params.selectedChangeFrames = [];% frames at which to introduce shifts (none)


params.trialsPerCond = 8;%
params.allTrials = Shuffle(repmat(1:length(params.targetShifts),1,params.trialsPerCond));
params.allTrials = [params.merConfig*ones(1,size(params.allTrials,2));2*ones(1,size(params.allTrials,2));params.allTrials];
params.trialSeq = randperm(size(params.allTrials,2));
params.allTrials = params.allTrials(:,params.trialSeq);


params.nTrials = size(params.allTrials,2);
params.maskOrder = Shuffle(repmat(1:params.nUniqueMasks,1,ceil(params.nTrials/params.nUniqueMasks)));
params.maskDur = .5;
params.ITI = .5;

pathname = pwd;
lastslash = find(pathname == '/',1,'last');
folder = pathname(lastslash+1:end);
params.filename = [params.subjID '_config' num2str(params.adaptConfig) '_r'  num2str(params.runNumber) '_' params.merLabels{params.merConfig} '_' params.saveLabels{params.controlCondition}  '_' folder '_' datestr(now,'mmddyyyy') '_' datestr(now,'HHMM')];

params.captureFileName = ['ScreenCapture_' datestr(now,'mmddyyyy') '_' datestr(now,'HHMM') '.mov']; %if doing screen capture

end