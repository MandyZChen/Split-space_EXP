function mov = setupMovieShift(params,display)

[mov.moviePtr,mov.dur,mov.origFps,mov.w,mov.h] = Screen('OpenMovie',display.w,[params.movieDir '/' params.movieName],[],10);


if params.customFps == 1
    mov.fps = params.fps;
end

mov.movieSize = [mov.w mov.h];%[480 360];%[640 480];
mov.timeKeep = nan(1,ceil(mov.dur*mov.fps));