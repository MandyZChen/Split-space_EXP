clearvars -except bootThresh* threshOut* all*

%config 1 - adapt right down
%config 2 - adapt left down

plotCols = {'b' 'r' 'b' 'r'};
file_type ='*vert*.mat';

arcmin = 1;
figure;
nConds = 2;

for c = 1:nConds
    
    files = uipickfiles('FilterSpec',file_type);
    for f = 1:length(files)
        load(files{f});
        eval(['history_' num2str(f) '= history;']);
    end
    
    relevantTrials = true(1,length(history.offset));
    
    
    if ~isempty(strfind(files{1},'vert'))
        relResp =  history.response(relevantTrials)'== -1;
        relOffsets  = -2*arcmin* history.offset(relevantTrials);%multiplied by 2 to get full vernier offset
    else
        relOffsets  = 2*arcmin* history.offset(relevantTrials);%multiplied by 2 to get full vernier offset
        relResp =  history.response(relevantTrials)'==1;
    end
    
    [a b boot_params] = j_fit_ak(relOffsets'-min(relOffsets), relResp,'logistic1',1);
    b = b+min(relOffsets);
    boot_params(:,2) = boot_params(:,2)+min(relOffsets);
    [xVals(c,:) percResp(c,:)] = percent_corr(relOffsets', relResp);
    hold on;scatter(xVals(c,:),percResp(c,:),700,['.' plotCols{c}]);
    xEval = min(history.offset*arcmin*2):.01:max(history.offset*arcmin*2);
    scale = 1;shift =0;
    yEval = scale./(1+exp(-a*(xEval-b)))+shift;
    hold on;h(c) = plot(xEval,yEval,plotCols{c},'LineWidth',2);
    threshOut(c) = b;
    bootThreshOut(:,:,c) = boot_params(:,2);
    %     threshOutTest(c,c+1) = b;
    %     end
end

set(gcf,'Position',[70   120   635   564])

if ~isempty(strfind(files{1},'vert'))
    yAxisLabel = 'Prop. left higher';
    xAxisLabel = 'Offset (deg) (- = left downward, + = left upward)';
    legendLabels = {'adapt left lower'  'adapt left higher'};
    
else
    yAxisLabel = 'Prop. top right responses';
    xAxisLabel = 'Offset (- = top leftward, + = top rightward)';
    legendLabels = {'adapt top right' 'adapt top left'};
end

legend(h,legendLabels);
ylabel(yAxisLabel);
xlabel(xAxisLabel);
ylim([0 1]);box on;
hold on;plot([min(xEval) max(xEval)],[.5 .5],'--k','LineWidth',2)
set(gca,'XTick',(-.4:.2:.4)*2*arcmin);
set(gca,'ticklength',2*get(gca,'ticklength'))
set(gca,'LineWidth',2)
fontSize = 24;
set(findall(gcf,'type','text'),'fontSize',fontSize); set(gca,'FontSize',fontSize)
