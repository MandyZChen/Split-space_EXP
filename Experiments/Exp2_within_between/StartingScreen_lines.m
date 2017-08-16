function [display] = StartingScreen_lines(params,display,tex)

if params.LocIndex == 0
    params.LocIndex =1;
    targetLocs = cell(1,4);
    for i = 1:4
        targetLocs{i} = repmat([display.center(1)-params.targetPixels(2) display.center(2)-params.targetPixels(1) display.center(1)+params.targetPixels(2) display.center(2)+params.targetPixels(1)]',1,2);
    end
    %     history.targetLocs = targetLocs;
    targetLocs{3}([1 3],1) = targetLocs{3}([1 3],1)-angle2pix(display,params.targetSep)-params.eccentricity(3);
    targetLocs{3}([1 3],2) = targetLocs{3}([1 3],2)+angle2pix(display,params.targetSep)-params.eccentricity(3);
    targetLocs{4}([1 3],1) = targetLocs{4}([1 3],1)-angle2pix(display,params.targetSep)+params.eccentricity(4);
    targetLocs{4}([1 3],2) = targetLocs{4}([1 3],2)+angle2pix(display,params.targetSep)+params.eccentricity(4);
    for i=1:2
        targetLocs{i}([1 3],1) = targetLocs{i}([1 3],1)-angle2pix(display,params.targetSep);
        targetLocs{i}([1 3],2) = targetLocs{i}([1 3],2)+angle2pix(display,params.targetSep);
    end
    
    targetLocs{1}([2 4],1) = targetLocs{1}([2 4],1)-params.eccentricity(1);
    targetLocs{1}([2 4],2) = targetLocs{1}([2 4],2)-params.eccentricity(1);
    targetLocs{2}([2 4],1) = targetLocs{2}([2 4],1)+params.eccentricity(2);
    targetLocs{2}([2 4],2) = targetLocs{2}([2 4],2)+params.eccentricity(2);
    for i=3:4
        targetLocs{i}([2 4],1) = targetLocs{i}([2 4],1);
        targetLocs{i}([2 4],2) = targetLocs{i}([2 4],2);
    end
    
    
    [keyIsDown,seconds,keyCode] = KbCheck(-1);
    while 1
        [keyIsDown,~,keyCode] = KbCheck(-1);
        Screen('DrawTexture', display.w, tex.fixTexW);
        for i = 1:4
            Screen('DrawTextures', display.w, tex.targetTex,[],targetLocs{i});
        end;
        Screen(display.w, 'TextSize',24);
        Screen(display.w,'DrawText','Press Space Bar to begin',50,30,255);
        Screen(display.w,'DrawText',['The lines will appear in the ' params.controlLabels{params.controlCondition} ' quadrant'],50,60,255);
         Screen(display.w,'DrawText',['Press upward arrow key if the left line is higher than the right line.'],50,90,255);
         Screen(display.w,'DrawText',['Press downward arrow key if the left line is lower than the right line.'],50,120,255);
         Screen(display.w,'DrawText',['Please keep fixating on the central dot throughout the experiment!'],50,150,255);

        display.vbl = Screen('Flip', display.w);
        
        if keyCode(KbName('Space'))
            break;
        end
    end
    
    HideCursor;
    WaitSecs(1);
    Screen(display.w, 'TextSize',10);
end
end
