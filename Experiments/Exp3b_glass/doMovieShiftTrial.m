function  [history, params] = doMovieShiftTrial(params,display,history,tex,trial)
% frTimer = tic;
if trial == 1 || rem(trial,params.topUpFreq) == 1
    % for each set of adapting stimuli, new set of dots and colors
    KbReleaseWait
    
    if  params.screenCapture == 1
        mov.movieRecPtr = Screen('CreateMovie', display.w, params.captureFileName, params.captureSize,params.captureSize,display.refresh);
    end
    %%%%%%%%%%%%%%%% RESETS SHIFT TO ZERO!!!!!!!!!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     params.currShift = 0;%starting shift %%%% RESETS SHIFT TO ZERO!!!!!!!!!!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    tmpColors = randi(256,3,params.nDots/params.propSel)-1;
    dotColors = repmat(tmpColors,1,params.propSel);
    
    
    angleFrameCounter = 0;
    
    
    dotCenters = nan(2,params.nDots);
    
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
    while toc(stimTimer)<runTime;
        history.frameCounter = history.frameCounter+1;
        angleFrameCounter = angleFrameCounter+1;%mod(angleFrameCounter,size(motionSets,2))+1;
        
        if any(ismember(params.selectedChangeFrames,history.frameCounter))
            params.currShift = params.currShift+params.shiftDirs(params.adaptConfig)*params.shiftInc;
            history.changeInd = [history.changeInd history.frameCounter];
            history.changeTime = [history.changeTime toc(stimTimer)];
        end
        
        if rem(angleFrameCounter,params.dotRefresh) == 1
            %select positions
            dotCenters(:,1:params.nDots/params.propSel) = randi(params.dotCenterBound*2+2,2,round(params.nDots/params.propSel))-(params.dotCenterBound+1);%x,y
            
            %rotate
            [ang,rh] = cart2pol(dotCenters(1,1:params.nDots/params.propSel),dotCenters(2,1:params.nDots/params.propSel));
            if params.randomRot
                [xAdd,yAdd] = pol2cart(deg2rad(randi(360,1,params.nDots/params.propSel)),params.eccSep);
                dotCenters(:,round(params.nDots/params.propSel)+1:round(params.nDots/(params.propSel/2))) =  dotCenters(:,1:params.nDots/params.propSel)+[xAdd;yAdd];
            else
                [dotCenters(1,round(params.nDots/params.propSel)+1:round(params.nDots/(params.propSel/2))), dotCenters(2,round(params.nDots/params.propSel)+1:round(params.nDots/(params.propSel/2)))] =  ...
                    pol2cart(ang+deg2rad(params.angularSep),rh+params.eccSep);
            end
            
            
            %scale
            dotCenters(1,round(params.nDots/params.propSel)+1:round(params.nDots/(params.propSel/2))) = params.xScale*dotCenters(1,round(params.nDots/params.propSel)+1:round(params.nDots/(params.propSel/2)));
            dotCenters(2,round(params.nDots/params.propSel)+1:round(params.nDots/(params.propSel/2))) = params.yScale*dotCenters(2,round(params.nDots/params.propSel)+1:round(params.nDots/(params.propSel/2)));
            
            %mirror flip (if applicable)
            if params.symmetric == 1;
                dotCenters(params.merConfig,(round(params.nDots/(params.propSel/2))+1):end) = -dotCenters(params.merConfig,1:params.nDots/(params.propSel/2));
                dotCenters(3-params.merConfig,(round(params.nDots/(params.propSel/2))+1):end) = dotCenters(3-params.merConfig,1:params.nDots/(params.propSel/2));
            end
            
            % shift both halves (if applicable)
            dotCenters(3-params.merConfig,dotCenters(params.merConfig,:)>0) =  dotCenters(3-params.merConfig,dotCenters(params.merConfig,:)>0)-params.currShift/2;
            dotCenters(3-params.merConfig,dotCenters(params.merConfig,:)<0) =  dotCenters(3-params.merConfig,dotCenters(params.merConfig,:)<0)+params.currShift/2;
            
        end
        
        
        %
        Screen('DrawDots', display.w,dotCenters, angle2pix(display,params.dotWidth),dotColors,display.center,1);
        
        %         WaitSecs(.1)
        
        if params.showOccluder == 1
            Screen('DrawTexture', display.w, tex.occluderTex,[],[],params.occluderAng);
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

%
%%%%% vernier task


trialOffset = params.targetShifts(params.allTrials(3,trial));


%%%%%%
if params.allTrials(1,trial) == 1 %vertical
    targetLocs = repmat([display.center(1)-params.targetPixels(2) display.center(2)-params.targetPixels(1) display.center(1)+params.targetPixels(2) display.center(2)+params.targetPixels(1)]',1,2);
    
    targetLocs([2 4],:) = targetLocs([2 4],:)+params.targetSides(params.allTrials(2,trial))*angle2pix(display,params.targetOffset);
    targetLocs([1 3],1) = targetLocs([1 3],1)-angle2pix(display,params.targetSep);
    targetLocs([1 3],2) = targetLocs([1 3],2)+angle2pix(display,params.targetSep);
    targetLocs([2 4],1) = targetLocs([2 4],1)+angle2pix(display,trialOffset);
    targetLocs([2 4],2) = targetLocs([2 4],2)-angle2pix(display,trialOffset);
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
    if params.merConfig == 1
        Screen('DrawTextures', display.w, tex.targetTex,[],targetLocs);
    else
        Screen('DrawTextures', display.w, tex.targetTex,[],targetLocs);
    end
    Screen('Flip', display.w);
end
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
        resp = -1;
        break;
    elseif keyCode(KbName(params.respKeys{params.allTrials(1,trial),2}));
        resp = 1;
        break;
    elseif keyCode(KbName('Escape'));
        Screen('CloseAll');
        break
    end
end
%ListenChar(0)
history.response = [history.response resp];
history.offset = [history.offset params.targetShifts(params.allTrials(3,trial))];
history.targetSide = [history.targetSide params.targetSides(params.allTrials(2,trial))];
history.targetConfig = [history.targetConfig params.allTrials(1,trial)];


if trial == 1 || rem(trial,params.topUpFreq) == 1
    history.faCount = [history.faCount faCount];
    history.targTimes = cat(3,history.targTimes,targTimes);
    history.hitOrMiss = cat(3,history.hitOrMiss,hitOrMiss);
    history.targLocs = cat(3,history.targLocs,targLocs);
end
end