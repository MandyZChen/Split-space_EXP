function history = makeMovieShiftHistory

history.totalDropped = [];
history.manualDropped = [];
history.droppedChanges = [];
history.changeInd = [];
history.changeTime = [];
history.response = [];
history.offset = [];
history.targetSide = [];
history.targetConfig = [];
history.frameCounter = 0;

history.startAngles=[];
history.angleSets=[];
history.origLineCenters=[];
history.motVectors=[];
history.lineColors=[];
history.lineLengths=[];

history.faCount = [];
history.targTimes = [];
history.hitOrMiss = [];
history.targLocs = [];

history.otStAngle = [];
history.otAngleSet = [];
history.otCenter=[];
history.otMotVect = [];
end