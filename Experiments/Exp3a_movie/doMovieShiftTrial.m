function  [history,mov,params] = doMovieShiftTrial(params,display,history,tex,mov,trial)

if trial == 1 || rem(trial,params.topUpFreq) == 1
    if trial == 1 && params.whichPart == 2;
        mov.stTime = params.initAdapt+((params.nTrials/params.topUpFreq)-1)*params.topUpAdapt;
    elseif trial == 1 && params.whichPart == 1;
        mov.stTime = 0;
    else
        mov.stTime = mov.time;
    end
    Screen('SetMovieTimeIndex', mov.moviePtr,mov.stTime);
    
    Screen('PlayMovie', mov.moviePtr, 1);
    if trial == 1 % on first trial, initialize some variables and start recording
        mov.frameCounter = 0;
        
        mov.time = mov.stTime;
        mov.nChanged = 0;
        mov.currScale = [params.startScale params.startScale];
        mov.currShift = zeros(2,4);
        mov.currShift(:,[params.shiftDim]) = repmat([params.shiftDirs(1)*params.startShift params.shiftDirs(2)*params.startShift]',1,2);
        
        if  params.screenCapture == 1
            mov.movieRecPtr = Screen('CreateMovie', display.w, params.captureFileName, params.captureSize,params.captureSize,mov.fps);
        end
        tic;
        runTime = mov.time+params.initAdapt;
    else
        runTime = mov.time+params.topUpAdapt;
    end
    
    targTimes = nan(1,ceil(max([params.initAdapt params.topUpAdapt])/min(params.ftTimeJitter)));
    hitOrMiss = nan(1,ceil(max([params.initAdapt params.topUpAdapt])/min(params.ftTimeJitter)));
    targLocs = nan(1,ceil(max([params.initAdapt params.topUpAdapt])/min(params.ftTimeJitter)));
    responded = 0;targOn= 0;missed = 0;fa = 0;faCount = 0;
    ftTimer = tic;
    stimTimer = tic;
    % main stimulus loop
    while (mov.time)<runTime
        mov.frameCounter = mov.frameCounter+1;
        % Wait for next movie frame, retrieve texture handle to it
        
        [movTmpTex mov.time]= Screen('GetMovieImage', display.w, mov.moviePtr,1);
        
        if mov.frameCounter >2
            mov.time = mov.time+params.offsetCorrection;
        end
        mov.timeKeep(mov.frameCounter) = mov.time;
        
        
        %%%% deal with dropped frames
        if mov.frameCounter>1
            if (mov.time-mov.timeKeep(mov.frameCounter-1))>((1/mov.fps)+params.timeTol)
                history.manualDropped = [history.manualDropped mov.frameCounter];
                
                %%%% deal with dropped frames where change was supposed to take place
                if any(ismember(params.selectedChangeFrames, mov.frameCounter))
                    history.droppedChanges = [history.droppedChanges mov.frameCounter];
                    possibleReplacements = params.possibleChangeFrames(params.possibleChangeFrames/mov.fps > mov.time & ~ismember(params.possibleChangeFrames,params.selectedChangeFrames));
                    
                    if isempty(possibleReplacements)
                        selReplacement = params.allCutFrames(find((params.allCutFrames-mov.frameCounter)>0,1,'first'));
                    else
                        selReplacement = possibleReplacements(randi(length(possibleReplacements)));
                    end
                    
                    params.selectedChangeFrames = sort([params.selectedChangeFrames selReplacement]);
                    params.selectedChangeTimes = params.selectedChangeFrames/mov.fps;
                end
            end
        end
        
        if any(abs(mov.time-params.selectedChangeTimes)<params.timeTol)
            %         disp(time)
            %         disp(cutChangeTimes)
            
            changeInd = find(abs(mov.time-params.selectedChangeTimes)<params.timeTol);
            side = params.whichSide(mov.nChanged+1);
            
            if params.scaleOrShift == 1 %not used for now...
                possibleScales = params.scaleAmts(params.scaleAmts~=mov.currScale(1) & params.scaleAmts~=mov.currScale(2));
                selectedScale = params.possibleScales(randi(length(possibleScales)));
                mov.currScale(side) = selectedScale;
                if params.calcByArea== 1
                    scaleFact = sqrt(100/selectedScale);
                else
                    scaleFact = (100/selectedScale);
                end
                if side == 2%2 for right
                    mov.dim2 = scaleFact*mov.origDim2;
                    
                else %1 for left
                    mov.dim1 = scaleFact*mov.origDim1;
                    
                end
            else
                mov.currShift(side,params.shiftDim) = mov.currShift(side,params.shiftDim)+params.shiftDirs(side)*params.shiftInc;
                
            end
            
            tic
            %         timeindex = Screen('GetMovieTimeIndex', mov.moviePtr);
            mov.nChanged = mov.nChanged+1;
            history.changeInd = [history.changeInd changeInd];
        end
        
        mov.movieW = [mov.dim1 mov.dim2]; %left, right
        mov.movieH = [mov.dim1 mov.dim2]; %left, right
        
        
        if params.merConfig == 1 %vertical
            if params.rot90 == 1
                
                % rotated 90 degrees
                % Left half
                Screen('DrawTexture', display.w, movTmpTex,[mov.movieCenter(1)-mov.movieW(1)/2 mov.movieCenter(2) mov.movieCenter(1)+mov.movieW(1)/2 mov.movieCenter(2)+mov.movieH(1)/2]-mov.currShift(1,:), ...
                    [display.center(1)-(3*params.destSize)/2 display.center(2)-params.destSize/2 display.center(1)+params.destSize/2 display.center(2)+params.destSize/2],90);
                % Right half
                Screen('DrawTexture', display.w, movTmpTex,[mov.movieCenter(1)-mov.movieW(2)/2 mov.movieCenter(2)-mov.movieH(2)/2 mov.movieCenter(1)+mov.movieW(2)/2 mov.movieCenter(2)]-mov.currShift(2,:), ...
                    [display.center(1)-params.destSize/2 display.center(2)-params.destSize/2 display.center(1)+(3*params.destSize)/2 display.center(2)+params.destSize/2],90);
                
            else
                Screen('DrawTexture', display.w, movTmpTex,[mov.movieCenter(1)-mov.movieW(1)/2 mov.movieCenter(2)-mov.movieH(1)/2 mov.movieCenter(1) mov.movieCenter(2)+mov.movieH(1)/2]-mov.currShift(1,:), ...
                    [display.center(1)-params.destSize display.center(2)-params.destSize display.center(1) display.center(2)+params.destSize],0);
                % Right half
                Screen('DrawTexture', display.w, movTmpTex,[mov.movieCenter(1) mov.movieCenter(2)-mov.movieH(2)/2 mov.movieCenter(1)+mov.movieW(2)/2 mov.movieCenter(2)+mov.movieH(2)/2]-mov.currShift(2,:), ...
                    [display.center(1) display.center(2)-params.destSize display.center(1)+params.destSize display.center(2)+params.destSize],0);
                
                
            end
        else 
            if params.rot90==1%horizontal
                
                % rotated 90 degrees
                % Top half
                Screen('DrawTexture', display.w, movTmpTex,[mov.movieCenter(1)-mov.movieW(1)/2 mov.movieCenter(2)-mov.movieH(1)/2 mov.movieCenter(1) mov.movieCenter(2)+mov.movieH(1)/2]-mov.currShift(1,:), ...
                    [display.center(1)-params.destSize/2 display.center(2)-3*params.destSize/2 display.center(1)+params.destSize/2 display.center(2)+params.destSize/2],90);
                % bottom half
                Screen('DrawTexture', display.w, movTmpTex,[mov.movieCenter(1) mov.movieCenter(2)-mov.movieH(2)/2 mov.movieCenter(1)+mov.movieW(2)/2 mov.movieCenter(2)+mov.movieH(2)/2]-mov.currShift(2,:), ...
                    [display.center(1)-params.destSize/2 display.center(2)-params.destSize/2 display.center(1)+params.destSize/2 display.center(2)+3*params.destSize/2],90);
                
            else
                % normal
                % Top half
                Screen('DrawTexture', display.w, movTmpTex,[mov.movieCenter(1)-mov.movieW(1)/2 mov.movieCenter(2)-mov.movieH(1)/2 mov.movieCenter(1)+mov.movieW(1)/2 mov.movieCenter(2)]-mov.currShift(1,:), ...
                    [display.center(1)-params.destSize display.center(2)-params.destSize display.center(1)+params.destSize display.center(2)],0);
                % bottom half
                Screen('DrawTexture', display.w, movTmpTex,[mov.movieCenter(1)-mov.movieW(2)/2 mov.movieCenter(2) mov.movieCenter(1)+mov.movieW(2)/2 mov.movieCenter(2)+mov.movieH(2)/2]-mov.currShift(2,:), ...
                    [display.center(1)-params.destSize display.center(2) display.center(1)+params.destSize display.center(2)+params.destSize],0);
            end
            
        end
        
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

        
        % Update display:
        Screen('Flip', display.w);
        
        % Release texture:
        Screen('Close', movTmpTex);
        
        if params.screenCapture == 1
            Screen('AddFrameToMovie', display.w, [display.center(1)-params.captureSize/2 display.center(2)-params.captureSize/2 ...
                display.center(1)+params.captureSize/2 display.center(2)+params.captureSize/2],[],mov.movieRecPtr)
        end
        
        keyIsDown = KbCheck(-1);%(4);
        %WaitSecs(.001);
        %         [~,~,btns] = GetMouse;
        %         keyIsDown= any(btns);
        if keyIsDown
            responded=1;
            
        end
        if fa == 1 && ~keyIsDown
            responded = 0;fa = 0;
            faCount = faCount+1;
        end
        
    end;
    
    droppedFrames= Screen('PlayMovie', mov.moviePtr, 0);
    
    %%%% transition screen
    history.totalDropped = [history.totalDropped droppedFrames];
    
    
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
ListenChar(2)
Screen('DrawTexture', display.w, tex.fixTexW);
Screen('Flip', display.w);
WaitSecs(params.ITI-1/display.refresh)
% Screen('DrawText', display.w, num2str(trial),512,384);

%

trialOffset = params.targetShifts(params.allTrials(3,trial));

%%%%% vernier task
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
    Screen('DrawTextures', display.w, tex.targetTex,[],targetLocs);
    
    Screen('Flip', display.w);
end


Screen('DrawTexture', display.w, tex.maskTex(params.maskOrder(trial)));
Screen('Flip', display.w);

WaitSecs(params.maskDur-1/display.refresh)
Screen('DrawTexture', display.w, tex.fixTexW);
Screen('Flip', display.w);

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
ListenChar(0)
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