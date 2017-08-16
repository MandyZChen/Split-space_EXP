function  [history, params] = doMovieShiftTrial(params,display,history,tex,trial)
% frTimer = tic;

if trial == 1 || rem(trial,params.topUpFreq) == 1
    % for each set of adapting stimuli, new set of lines and colors
    KbReleaseWait
    
    %%%%%%%%%%%%%%%% RESETS SHIFT TO ZERO!!!!!!!!!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     params.currShift = 0;%starting shift %%%% RESETS SHIFT TO ZERO!!!!!!!!!!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    startAngles = randi(360,1,params.nLines);
    angleSets = 90*sawtooth(repmat(0:(1/display.refresh):(2*pi),params.nLines,1)+(2*pi*repmat(rand(params.nLines,1),1,size(0:(1/display.refresh):(2*pi),2))),.5);
    
    lineColors = nan(3,params.nLines*2);
    lineTmpColors = randi(256,3,params.nLines)-1;
    lineColors(:,1:2:end) = lineTmpColors;
    lineColors(:,2:2:end) = lineTmpColors;
    
    lineCenters = randi(params.lineCenterBound*2+2,2,params.nLines)-(params.lineCenterBound+1);%x,y
    while any(lineCenters(:)==0)
        lineCenters = randi(params.lineCenterBound*2+2,2,params.nLines)-(params.lineCenterBound+1);%x,y %weird things happen if start center is exactly at zero
    end
    origLineCenters = lineCenters;
    th=2*pi*rand(1,params.nLines);
    shiftX=params.lineVel*cos(th);
    shiftY=params.lineVel*sin(th);
    lineLengths = (params.lengthRange(2)-params.lengthRange(1))*rand(1,params.nLines)+params.lengthRange(1);
    lineInd = sort(repmat(1:params.nLines,1,2));%
    angleFrameCounter = 0;
    
    shiftSteps =zeros(1,params.nLines);
    
    if trial == 1 % on first trial, initialize some variables and start recording
        runTime = params.initAdapt;
    else
        runTime = params.topUpAdapt;
    end
    targTimes = nan(1,ceil(max([params.initAdapt params.topUpAdapt])/min(params.ftTimeJitter)));
    hitOrMiss = nan(1,ceil(max([params.initAdapt params.topUpAdapt])/min(params.ftTimeJitter)));
    targLocs = nan(1,ceil(max([params.initAdapt params.topUpAdapt])/min(params.ftTimeJitter)));
    
    
    responded = 0;targOn= 0;missed = 0;fa = 0;faCount = 0;
    stimTimer = tic;
    ftTimer = tic;
    while toc(stimTimer)<runTime;% main stimulus loop
        history.frameCounter = history.frameCounter+1;
        angleFrameCounter = mod(angleFrameCounter,size(angleSets,2))+1;
        
        linePos = nan(2,params.nLines*2);
        posAtCross = nan(1,params.nLines);
        
        if any(ismember(params.selectedChangeFrames,history.frameCounter))
            params.currShift = params.currShift+params.shiftDirs(params.adaptConfig)*params.shiftInc;
            history.changeInd = [history.changeInd history.frameCounter];
            history.changeTime = [history.changeTime toc(stimTimer)];
        end
        
        changeX = lineCenters(1,:)+shiftX > params.lineCenterBound | lineCenters(1,:)+shiftX < -params.lineCenterBound;
        shiftX(changeX) = -shiftX(changeX);
        changeY = lineCenters(2,:)+shiftY > params.lineCenterBound | lineCenters(2,:)+shiftY < -params.lineCenterBound;
        shiftY(changeY) = -shiftY(changeY);
        lineCenters = lineCenters+[shiftX;shiftY];
        
        
        lineAngles = mod(startAngles+angleSets(:,angleFrameCounter)',360);%lineAngles = 90*ones(1,length(lineAngles));
        %     lineAngles(ismember(lineAngles,45:90:315)) = lineAngles(ismember(lineAngles,45:90:315))+randi(2,1,sum(ismember(lineAngles,45:90:315)))*2-3;
        [xOffsets,yOffsets] = pol2cart((pi/180)*(lineAngles),angle2pix(display,lineLengths/2));
        linePos(:,1:2:params.nLines*2) = (lineCenters-[xOffsets;yOffsets]);%start locations
        linePos(:,2:2:params.nLines*2) = (lineCenters+[xOffsets;yOffsets]);% end locations
        merCross = sign(diff(sign(reshape(linePos(params.merConfig,:),2,params.nLines)))); %whether crosses vertical meridian, and in which direction
        
        
        if angleFrameCounter>1
            
            set1 = logical(sum([(origLineCenters(params.merConfig,:)>=0) & (mod(lineAngles,360)>params.orientBounds(params.merConfig,1) & mod(lineAngles,360)<=params.orientBounds(params.merConfig,2)) ; (origLineCenters(params.merConfig,:)<0 & (mod(lineAngles,360)<=params.orientBounds(params.merConfig,1) | mod(lineAngles,360)>params.orientBounds(params.merConfig,2)))]));%]));
            set2 = logical(sum([(origLineCenters(params.merConfig,:)<0) & (mod(lineAngles,360)>params.orientBounds(params.merConfig,1) & mod(lineAngles,360)<=params.orientBounds(params.merConfig,2)) ; (origLineCenters(params.merConfig,:)>=0 & (mod(lineAngles,360)<=params.orientBounds(params.merConfig,1) | mod(lineAngles,360)>params.orientBounds(params.merConfig,2)))]));%]));%criteria for ones that start on the left
            
            
            
            switchInd = [logical(sum([set1 & merCross==0 & prevMerCross~=0 & sign(lineCenters(params.merConfig,:))~=sign(origLineCenters(params.merConfig,:));set2 & merCross==0 & prevMerCross~=0 & sign(lineCenters(params.merConfig,:))==sign(origLineCenters(params.merConfig,:))])); ...
                logical(sum([set1 & merCross~=0 & prevMerCross==0 & sign(lineCenters(params.merConfig,:))~=sign(origLineCenters(params.merConfig,:));set2 & merCross~=0 & prevMerCross==0 & sign(lineCenters(params.merConfig,:))==sign(origLineCenters(params.merConfig,:))]))];
            
            
            
            if any(switchInd(1,:));%sign(lineCenters(1,switchInd))~=sign(origLineCenters(1,switchInd));
                shiftSteps(switchInd(1,:)) = params.currShift*(4*(mod(lineAngles(switchInd(1,:)==1),360)<=params.orientBounds(params.merConfig,1) | mod(lineAngles(switchInd(1,:)==1),360)>params.orientBounds(params.merConfig,2))-2)/2;%
                lineCenters(3-params.merConfig,switchInd(1,:)) = lineCenters(3-params.merConfig,switchInd(1,:))+shiftSteps(switchInd(1,:));
                %             shiftSteps
            end
            if any(switchInd(2,:))
                shiftSteps(switchInd(2,:)) = -params.currShift*(4*(mod(lineAngles(switchInd(2,:)==1),360)<=params.orientBounds(params.merConfig,1) | mod(lineAngles(switchInd(2,:)==1),360)>params.orientBounds(params.merConfig,2))-2)/2;%
                lineCenters(3-params.merConfig,switchInd(2,:)) = lineCenters(3-params.merConfig,switchInd(2,:))+shiftSteps(switchInd(2,:));
                %             shiftSteps
            end
        end
        linePos(:,1:2:params.nLines*2) = (lineCenters-[xOffsets;yOffsets]);%start locations
        linePos(:,2:2:params.nLines*2) = (lineCenters+[xOffsets;yOffsets]);% end locations
        
        insertLocs = find(ismember(lineInd,find(merCross)));
        slopeSigns =-(4*(mod(lineAngles,360)>180 & mod(lineAngles,360)<360)-2)/2;
        % slopeSigns(lineInd(insertLocs(1:2:end))).*
        slopes = (linePos(2,insertLocs(2:2:end))-linePos(2,insertLocs(1:2:end)))./(linePos(1,insertLocs(2:2:end))-linePos(1,insertLocs(1:2:end)));
        intercepts = linePos(2,insertLocs(1:2:end))-slopes.*linePos(1,insertLocs(1:2:end));
        if params.merConfig == 2
            intercepts = -intercepts./slopes;
        end
        posAtCross(merCross~=0) = intercepts; %
        
        
        
        newLinePos = nan(2,size(linePos,2)+size(insertLocs,2));
        newLineColors = nan(3,size(linePos,2)+size(insertLocs,2));
        
        
        for i = 1:2:length(insertLocs) %awkward, but works!
            
            if i == 1
                startLoc = 1;
                
                startI = find(isnan(newLinePos(1,:)),1,'first');
                
                if params.merConfig == 1
                    newLinePos(:,startI:startI+(length(startLoc:(insertLocs(i)))+1)) = [linePos(:,startLoc:(insertLocs(i))) repmat([0;posAtCross(lineInd(insertLocs(i)))],1,2)+[0 0;0 params.currShift*((merCross(lineInd(insertLocs(i)))))]];
                else
                    newLinePos(:,startI:startI+(length(startLoc:(insertLocs(i)))+1)) = [linePos(:,startLoc:(insertLocs(i))) repmat([posAtCross(lineInd(insertLocs(i)));0],1,2)+[0 params.currShift*((merCross(lineInd(insertLocs(i)))));0 0]];
                end
            else
                
                startI = find(isnan(newLinePos(1,:)),1,'first');
                startLoc = (insertLocs(i-1));
                
                if params.merConfig == 1
                    newLinePos(:,startI:startI+(length(startLoc:(insertLocs(i)))+1)) = [linePos(:,startLoc:(insertLocs(i)))+[zeros(1,length(startLoc:(insertLocs(i))));params.currShift*((merCross(lineInd(insertLocs(i-1))))) zeros(1,length(startLoc:(insertLocs(i)))-1)] ...
                        repmat([0;posAtCross(lineInd(insertLocs(i)))],1,2)+[0 0;0 params.currShift*((merCross(lineInd(insertLocs(i)))))]];
                else
                    newLinePos(:,startI:startI+(length(startLoc:(insertLocs(i)))+1)) = [linePos(:,startLoc:(insertLocs(i)))+[params.currShift*((merCross(lineInd(insertLocs(i-1))))) zeros(1,length(startLoc:(insertLocs(i)))-1);zeros(1,length(startLoc:(insertLocs(i))))] ...
                        repmat([posAtCross(lineInd(insertLocs(i)));0],1,2)+[0 params.currShift*((merCross(lineInd(insertLocs(i)))));0 0]];
                end
            end
            
            
            newLineColors(:,startI:startI+(length(startLoc:(insertLocs(i)))+1)) = [lineColors(:,startLoc:(insertLocs(i))) repmat(lineColors(:,insertLocs(i)),1,2)];
        end
        
        
        if ~isempty(insertLocs)
            
            startI = find(isnan(newLinePos(1,:)),1,'first');
            if params.merConfig == 1
                newLinePos(:,startI:end) = linePos(:,insertLocs(end):end)+[zeros(1,length(linePos)-insertLocs(end)+1);params.currShift*((merCross(lineInd(insertLocs(i))))) zeros(1,length(linePos)-insertLocs(end))];
                newLineColors(:,startI:end) = lineColors(:,insertLocs(end):end);
            else
                newLinePos(:,startI:end) = linePos(:,insertLocs(end):end)+[params.currShift*((merCross(lineInd(insertLocs(i))))) zeros(1,length(linePos)-insertLocs(end));zeros(1,length(linePos)-insertLocs(end)+1)];
                newLineColors(:,startI:end) = lineColors(:,insertLocs(end):end);
            end
        else
            newLinePos = linePos;
            newLineColors = lineColors;
        end
        
        linePos = round(newLinePos);%whole pixels
        
        prevMerCross = merCross;
        %
        if params.controlCondition ==3
            Screen('DrawLines', display.w,linePos, angle2pix(display,params.lineWidth),newLineColors,display.center-[(params.eccentricity(params.controlCondition)),0],1);
        elseif params.controlCondition ==4
            Screen('DrawLines', display.w,linePos, angle2pix(display,params.lineWidth),newLineColors,display.center+ [(params.eccentricity(params.controlCondition)),0],1);
        else
            Screen('DrawLines', display.w,linePos, angle2pix(display,params.lineWidth),newLineColors,display.center,1);
        end;
        
        if params.showOccluder == 1
            Screen('DrawTexture', display.w, tex.occluderTex,[],tex.occluderRect,params.occluderAng);
            
        end
        if params.showApert == 1
            Screen('DrawTexture', display.w, tex.overlayTex);
        end
        
        if (toc(ftTimer)+(1/display.refresh))>=params.ftNextTime && (runTime-(toc(stimTimer)))>params.ftRespInt
            ftInd = find(isnan(targLocs),1,'first');
            hitOrMiss(ftInd)= 1-missed;
            
            ftTimer = tic;
            targOn = 1;missed = 0;fa = 0;
            whichTarg = randi(length(tex.fixTargTex));
            params.ftNextTime = params.ftTimeJitter(1)+(params.ftTimeJitter(2)-params.ftTimeJitter(1))*rand;
            targLocs(ftInd) = whichTarg;
            targTimes(ftInd) = params.ftNextTime;
        end
        
        if targOn && (toc(ftTimer)+1/display.refresh)<params.ftDur
            
            Screen('DrawTexture', display.w, tex.fixTargTex(whichTarg));
        else
            Screen('DrawTexture', display.w, tex.fixTexW);
        end
        
        
        
        if targOn == 0 && responded==1
            fa = 1;
            Screen('DrawTexture', display.w, tex.fixTexR);
        end
        
        %misses
        if toc(ftTimer)>params.ftRespInt && responded == 0 && targOn == 1
            missed = 1;
        end
        
        if missed ==1 && toc(ftTimer)<(params.ftRespInt+params.ftRespRed)
            Screen('DrawTexture', display.w, tex.fixTexR);
        end
        
        if toc(ftTimer)>params.ftRespInt
            targOn = 0;
            responded = 0;
        end
        
        
        display.vbl = Screen('Flip', display.w,display.vbl);
        
        
        if params.screenCapture == 1
            Screen('AddFrameToMovie', display.w, [display.center(1)-params.captureSize/2 display.center(2)-params.captureSize/2 ...
                display.center(1)+params.captureSize/2 display.center(2)+params.captureSize/2],[],mov.movieRecPtr)
        end
        %
        keyIsDown = KbCheck(-1);%(4);
        if keyIsDown
            responded=1;
            
        end
        if fa == 1 && ~keyIsDown
            responded = 0;fa = 0;
            faCount = faCount+1;
        end
        
    end;
    
    for i = 1
        Screen('DrawTexture', display.w, tex.fixTexB);
        Screen('Flip', display.w);
        WaitSecs(.25-1/display.refresh);
        Screen('DrawTexture', display.w, tex.fixTexW);
        Screen('Flip', display.w)
        WaitSecs(.25-1/display.refresh);
    end
    
    ftInd = find(isnan(targLocs),1,'first');
    hitOrMiss(ftInd) =1-missed;
    
    
    Screen('DrawText', display.w, num2str(100*(trial-1)/params.nTrials,2), display.center(1)-5,display.center(2)-5);
    Screen('Flip', display.w)
    WaitSecs(.5);
    
    
end

%ListenChar(2)
Screen('DrawTexture', display.w, tex.fixTexW);
Screen('Flip', display.w);
WaitSecs(params.ITI-1/display.refresh)


trialOffset = params.targetShifts(params.allTrials(3,trial));


%%%%%%
if params.allTrials(1,trial) == 1 %vertical
    targetLocs=[];
    targetLocs = repmat([display.center(1)-params.targetPixels(2) display.center(2)-params.targetPixels(1) display.center(1)+params.targetPixels(2) display.center(2)+params.targetPixels(1)]',1,2);
    
    targetLocs([2 4],:) = targetLocs([2 4],:)+params.targetSides(params.allTrials(2,trial))*angle2pix(display,params.targetOffset);
    if params.controlCondition == 3
        targetLocs([1 3],1) = targetLocs([1 3],1)-angle2pix(display,params.targetSep)-params.eccentricity(params.controlCondition);
        targetLocs([1 3],2) = targetLocs([1 3],2)+angle2pix(display,params.targetSep)-params.eccentricity(params.controlCondition);
    elseif params.controlCondition == 4
        targetLocs([1 3],1) = targetLocs([1 3],1)-angle2pix(display,params.targetSep)+params.eccentricity(params.controlCondition);
        targetLocs([1 3],2) = targetLocs([1 3],2)+angle2pix(display,params.targetSep)+params.eccentricity(params.controlCondition);
    else
        targetLocs([1 3],1) = targetLocs([1 3],1)-angle2pix(display,params.targetSep);
        targetLocs([1 3],2) = targetLocs([1 3],2)+angle2pix(display,params.targetSep);
    end;
    
    if params.controlCondition == 1
        targetLocs([2 4],1) = targetLocs([2 4],1)+angle2pix(display,trialOffset)-params.eccentricity(params.controlCondition);
        targetLocs([2 4],2) = targetLocs([2 4],2)-angle2pix(display,trialOffset)-params.eccentricity(params.controlCondition);
    elseif params.controlCondition == 2
        targetLocs([2 4],1) = targetLocs([2 4],1)+angle2pix(display,trialOffset)+params.eccentricity(params.controlCondition);
        targetLocs([2 4],2) = targetLocs([2 4],2)-angle2pix(display,trialOffset)+params.eccentricity(params.controlCondition);
    else
        targetLocs([2 4],1) = targetLocs([2 4],1)+angle2pix(display,trialOffset);
        targetLocs([2 4],2) = targetLocs([2 4],2)-angle2pix(display,trialOffset);
    end;
    
elseif params.allTrials(1,trial) == 2 %horizontal
    targetLocs = repmat([display.center(1)-params.targetPixels(1) display.center(2)-params.targetPixels(2) display.center(1)+params.targetPixels(1) display.center(2)+params.targetPixels(2)]',1,2);
    
    targetLocs([1 3],:) = targetLocs([1 3],:)+params.targetSides(params.allTrials(2,trial))*angle2pix(display,params.targetOffset);
    targetLocs([2 4],1) = targetLocs([2 4],1)-angle2pix(display,params.targetSep);
    targetLocs([2 4],2) = targetLocs([2 4],2)+angle2pix(display,params.targetSep);
    targetLocs([1 3],1) = targetLocs([1 3],1)+angle2pix(display,trialOffset);
    targetLocs([1 3],2) = targetLocs([1 3],2)-angle2pix(display,trialOffset);
end


for f = 1:params.targetFrames
    Screen('DrawTexture', display.w, tex.fixTexW);
    Screen('DrawTextures', display.w, tex.targetTex,[],targetLocs);
    Screen('Flip', display.w);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for random line: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% otStartAngle = params.otAngles(randi(length(params.otAngles)));
% % otAngleSet = 90*sawtooth((0:(1/display.refresh):(2*pi))+(2*pi*repmat(rand,1,size(0:(1/display.refresh):(2*pi),2))),.5);
% otAngleSet = (2*randi(2)-3)*90*(sawtooth((0:(1/display.refresh):(2*pi))+pi/2,.5));
% otLineCenters = randi(angle2pix(display,params.otJitter)*2+2,2,1)-(angle2pix(display,params.otJitter+1));%x,y
% while any(otLineCenters(:)==0)
%     otLineCenters = randi(angle2pix(display,params.otJitter)*2+2,2,1)-(angle2pix(display,params.otJitter)+1);%x,y %weird things happen if start center is exactly at zero
% end
% otLineCenters(3-params.merConfig,:) = otLineCenters(3-params.merConfig,:)+params.targetSides(params.allTrials(2,trial))*angle2pix(display,params.targetOffset);
% origOtLineCenters = otLineCenters;
% otTh=2*pi*rand;
% otShiftX=params.lineVel*cos(otTh);
% otShiftY=params.lineVel*sin(otTh);
%
% for otFr = 1:params.targetFrames
%     otPos = [nan;nan];%l(2,params.nLines*2);
%
%     otLineCenters = otLineCenters+[otShiftX;otShiftY];
%
%
%     otAngle = mod(otStartAngle+otAngleSet(otFr)',360);%lineAngles = 90*ones(1,length(lineAngles));
%
%     %     lineAngles(ismember(lineAngles,45:90:315)) = lineAngles(ismember(lineAngles,45:90:315))+randi(2,1,sum(ismember(lineAngles,45:90:315)))*2-3;
%     [otXOffsets,otYOffsets] = pol2cart((pi/180)*(otAngle),angle2pix(display,params.otLength/2));
%     otPos(:,1) = (otLineCenters-[otXOffsets;otYOffsets]);%start locations
%     otPos(:,2) = (otLineCenters+[otXOffsets;otYOffsets]);% end locations
%
%     otSlope = (otPos(3-params.merConfig,2)-otPos(3-params.merConfig,1))./(otPos(params.merConfig,2)-otPos(params.merConfig,1));
%     otIntercept = otPos(3-params.merConfig,1)-otSlope.*otPos(params.merConfig,1);
%     otMerCross = sign(diff(sign(reshape(otPos(params.merConfig,:),2,1)))); %whether crosses vertical meridian, and in which direction
%
%
%     if params.merConfig == 1
%         otNewLinePos = [otPos(:,1) repmat([0;otIntercept],1,2)+[0 0;-angle2pix(display,params.targetShifts(params.allTrials(3,trial)))*((otMerCross)) angle2pix(display,params.targetShifts(params.allTrials(3,trial)))*((otMerCross))] otPos(:,2)];
%     else
%         otNewLinePos = [otPos(:,1) repmat([otIntercept;0],1,2)+[-angle2pix(display,params.targetShifts(params.allTrials(3,trial)))*((otMerCross)) angle2pix(display,params.targetShifts(params.allTrials(3,trial)))*((otMerCross));0 0] otPos(:,2)];
%     end
%     otPos = round(otNewLinePos);
%
%     Screen('DrawLines', display.w,otPos, angle2pix(display,params.lineWidth),params.otColor,display.center,1);
%     %
%     if params.showOccluder == 1
%         Screen('DrawTexture', display.w, tex.occluderTex,[],[],params.occluderAng);
%     end
%     if params.showApert == 1
%         Screen('DrawTexture', display.w, tex.overlayTex);
%     end
%
%     Screen('DrawTexture', display.w, tex.fixTexW);
%     Screen('Flip', display.w);
%
% end
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



Screen('DrawTexture', display.w, tex.maskTex(params.maskOrder(trial)));
Screen('Flip', display.w);

WaitSecs(params.maskDur-1/display.refresh)

Screen('DrawTexture', display.w, tex.fixTexW);
display.vbl = Screen('Flip', display.w);

[keyIsDown,seconds,keyCode] = KbCheck(-1);
while 1
    [keyIsDown,~,keyCode] = KbCheck(-1);
    if keyCode(KbName(params.respKeys{params.allTrials(1,trial),1}))
        resp = -1; % Up arrow key
        break;
    elseif keyCode(KbName(params.respKeys{params.allTrials(1,trial),2}))
        resp = 1;% down arrow key
        break;
    elseif keyCode(KbName('Escape'))
        Screen('CloseAll');
        break
    end
end

%% Presenting feedback!
correct = 0;
if params.feedback == 1
    if resp == -1
        if (targetLocs([2 4],1) <= targetLocs([2 4],2))
            Screen('DrawTexture', display.w, tex.fixTexB);
            correct = 1;
        else
            Screen('DrawTexture', display.w, tex.fixTexR);
            correct = -1;
        end;
    elseif resp == 1
        if (targetLocs([2 4],1) >= targetLocs([2 4],2))
            Screen('DrawTexture', display.w, tex.fixTexB);
            correct = 1;
        else
            Screen('DrawTexture', display.w, tex.fixTexR);
            correct = -1;
        end;
    end;
    display.vbl = Screen('Flip', display.w);
WaitSecs(0.5);
end;

    
%ListenChar(0)
history.response = [history.response resp];
history.correct = [history.correct correct];
history.offset = [history.offset params.targetShifts(params.allTrials(3,trial))];
history.targetSide = [history.targetSide params.targetSides(params.allTrials(2,trial))];
history.targetConfig = [history.targetConfig params.allTrials(1,trial)];
% history.otStAngle = [history.otStAngle  otStartAngle];
% history.otAngleSet = [history.otAngleSet otAngleSet'];
% history.otCenter=[history.otCenter origOtLineCenters];
% % history.otMotVect = [history.otMotVect otTh];
% history.offset=[history.offset trialOffset];


if trial == 1 || rem(trial,params.topUpFreq) == 1
    history.startAngles= cat(2,history.startAngles,startAngles');
    history.angleSets = cat(3,history.angleSets,angleSets);
    history.origLineCenters = cat(3,history.origLineCenters,origLineCenters);%(:,:,trial) = origLineCenters;
    history.motVectors = cat(2,history.motVectors,th');%(:,trial) = th;
    history.lineColors = cat(3,history.lineColors,lineColors);%(:,:,trial) = lineColors;
    history.lineLengths = cat(2,history.lineLengths,lineLengths');%(:,:,trial) = lineLengths;
    history.faCount = [history.faCount faCount];
    history.targTimes = cat(3,history.targTimes,targTimes);
    history.hitOrMiss = cat(3,history.hitOrMiss,hitOrMiss);
    history.targLocs = cat(3,history.targLocs,targLocs);
end
end