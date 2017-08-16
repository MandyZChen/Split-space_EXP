function tex = makeMovieShiftTextures(display,params)

%occluder
occluderMat = display.black*ones(params.destSize*2,angle2pix(display,params.occluderWidth));
tex.occluderTex= Screen('MakeTexture',display.w,uint8(occluderMat));


% setup for aperture
xyRange = linspace(-params.apertSize, params.apertSize, params.apertPixels*2);
[x,y] = meshgrid(xyRange);
% aperture
if params.apertType == 1
    % gaussian aperture overlay
    gaussMat = exp(-(x.^2+y.^2)./(2*params.apertGaussSD^2)); %plug x and y into the formula for a 2D Gaussian
    gaussMatAdj = params.apertMaxL*(1-gaussMat); %adjust intensity values
    overlayMat = zeros(size(gaussMatAdj,1),size(gaussMatAdj,1),3);
    overlayMat(:,:,4) = gaussMatAdj;
elseif params.apertType == 2
    % circular aperture with gaussian dropoff
    radiusMat=sqrt(x.^2+y.^2);
    ringMat = exp(-((radiusMat-params.apertRadius).^2)./(2*params.gaussDropSD^2));
    circleMat = (radiusMat<params.apertRadius);
    apertMat = 1-ringMat;
    apertMat(circleMat==1) = 0;
    overlayMat = zeros(size(radiusMat,1),size(radiusMat,1),3);
    overlayMat(:,:,4) = (params.apertMaxL-params.apertMinL).*apertMat+params.apertMinL;
    
end
tex.overlayTex = Screen('MakeTexture',display.w,uint8(overlayMat));


% targets
if params.targetType == 1
    xyRange = linspace(-params.targetSize, params.targetSize, params.targetPixels(1)*2);
    [x,y] = meshgrid(xyRange);
    targetMat = exp(-(x.^2+y.^2)./(2*params.targetGaussSD^2)); %plug x and y into the formula for a 2D Gaussian
    targetMatAdj = params.targetMaxL*targetMat;
    tex.targetTex = Screen('MakeTexture',display.w,uint8(targetMatAdj));
elseif params.targetType == 2
    targetMat = params.targetMaxL*ones(angle2pix(display,params.targetH),angle2pix(display,params.targetW));
    tex.targetTex = Screen('MakeTexture',display.w,uint8(targetMat));
end

for m = 1:params.nUniqueMasks;
    noiseMat = imresize(randi(256,params.noiseSq,params.noiseSq)-1,[params.noiseSize*2 params.noiseSize*2],'nearest');
    noiseMat=2*((noiseMat-min(noiseMat(:)))./(max(noiseMat(:))-min(noiseMat(:))))-1;
    noiseMat = params.noiseMeanL+(params.noiseMeanL*params.noiseContrast*noiseMat);
    if params.noiseApertured
        %         noiseMat = repmat(noiseMat,[1 1 3]);
        noiseMat = repmat(padarray(noiseMat,(size(apertMat)-size(noiseMat))/2,0,'both'),[1 1 3]);
        noiseMat(:,:,4) = params.apertMaxL*(1-apertMat);%(255-overlayMat(:,:,4));%params.apertMaxL*(1-apertMat);
    end
    tex.maskTex(m) = Screen('MakeTexture',display.w,uint8(noiseMat));
end

% %fixation (white)
% fixMatW = display.black*ones(angle2pix(display,params.fixLength));
% fixMatW(ceil(angle2pix(display,params.fixLength)/2),:) = 255;
% fixMatW(:,ceil(angle2pix(display,params.fixLength)/2)) = 255;

[x,y] = meshgrid(linspace(-params.fixLength/2,params.fixLength/2,angle2pix(display,params.fixLength)));
fixMatW=255*(sqrt(x.^2+y.^2)<params.fixLength/2);
possLocs = find((sqrt(x.^2+y.^2)<((params.fixLength/2)-pix2angle(display,2))));
for i = 1:length(possLocs)
   fixTargMatTmp = fixMatW;
    [tRow,tCol] = ind2sub(size(fixMatW),possLocs(i));
    fixTargMatTmp(tRow-params.fixPadding:tRow+params.fixPadding,tCol-params.fixPadding:tCol+params.fixPadding)=params.ftIntensity;
  
    tex.fixTargTex(i) = Screen('MakeTexture',display.w,uint8(fixTargMatTmp));
end
% fixMatW = display.black*ones(angle2pix(display,params.fixLength));
% fixMatW(ceil(angle2pix(display,params.fixLength)/2),:) = 255;
% fixMatW(:,ceil(angle2pix(display,params.fixLength)/2)) = 255;



%fixation (red)
fixMatR = repmat(fixMatW,[1 1 3]);
fixMatR(:,:,[2 3]) = 0;

%fixation (blue)
fixMatB = repmat(fixMatW,[1 1 3]);
fixMatB(:,:,[1 2]) = 0;

tex.fixTexW = Screen('MakeTexture',display.w,uint8(fixMatW));
tex.fixTexR = Screen('MakeTexture',display.w,uint8(fixMatR));
tex.fixTexB = Screen('MakeTexture',display.w,uint8(fixMatB));

end