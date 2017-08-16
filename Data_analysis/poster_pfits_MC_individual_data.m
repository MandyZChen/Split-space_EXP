% clear all;
% close all;
clearvars -except bootThresh* threshOut* all*

%config 1 - adapt right down
%config 2 - adapt left down
file_type ='*vert*.mat'; % '*horiz*.mat';

plotCols = cell(1,2);
plotCols{1} = [0,0,1];
plotCols{2} = [1,0,0];

subject_num = 8;
% subject_sign={'+','*','s','d','^','v','<','>','o'};
subject_sign={'o'};
arcmin = 1;
figure;
nConds = 2;

for sub = 1:(subject_num)
    
    for c = 1:nConds
        
        files = uipickfiles('FilterSpec','*horiz*.mat');
        for f = 1:length(files)
            load(files{f});
            eval(['history_' num2str(f) '= history;']);
            eval(['params_' num2str(f) '= params;']);
        end
        
        clear history;
        hist_fields = fieldnames(history_1);
        
        history.response =[];
        history.offset =[];
        
        for f = 1:length(files)
            eval(['history.response = [history.response history_' num2str(f) '.response];']);
            eval(['history.offset = [history.offset history_' num2str(f) '.offset];']);
        end
        
        relevantTrials = true(1,length(history.offset));
        
        if ~isempty(strfind(files{1},'vert'))
            relResp =  history.response(relevantTrials)'== -1;
            relOffsets  = -2*arcmin* history.offset(relevantTrials);%multiplied by 2 to get full vernier offset
        else
            relOffsets  = 2*arcmin* history.offset(relevantTrials);%multiplied by 2 to get full vernier offset
            relResp =  history.response(relevantTrials)'==1;
        end
        
        subplot(2,4,sub);
        
        [a b boot_params] = j_fit_ak(relOffsets'-min(relOffsets), relResp,'logistic1',1);
        b = b+min(relOffsets);
        boot_params(:,2) = boot_params(:,2)+min(relOffsets);
        [xVals(c,:) percResp(c,:)] = percent_corr(relOffsets', relResp);
        hold on;
        scatter(xVals(c,:),percResp(c,:),50,[subject_sign{1}],'MarkerEdgeColor',plotCols{c},'MarkerFaceColor',plotCols{c});
        xEval = min(history.offset*arcmin*2):.01:max(history.offset*arcmin*2);
        scale = 1;shift =0;
        yEval = scale./(1+exp(-a*(xEval-b)))+shift;
        hold on;
        h(c) = plot(xEval,yEval,'LineWidth',2,'Color',plotCols{c});
        threshOut(c) = b;
        bootThreshOut(:,:,c) = boot_params(:,2);
    end
    
    set(gcf,'Position',[70   120   635   564])
    
    if ~isempty(strfind(files{1},'vert'))
        yAxisLabel = 'Prop. left higher';
        xAxisLabel = 'Offset (deg) (- = left downward, + = left upward)';
        legendLabels = {'adapt left lower'  'adapt left higher'};
        
    else
        yAxisLabel = 'Prop. top right responses';
        xAxisLabel = 'Offset (- = top leftward, + = top rightward)';
        legendLabels = {'adapt top right'  'adapt top left'};
    end
    
    Format_graphs;
    
    if (sub == 1) || (sub == 4)
        % legend(h,legendLabels);
        ylabel(yAxisLabel);
        xlabel(xAxisLabel);
    end
    %         axis equal;
    ylim([0 1]);
    xlim([-1 1]);
    box on;
    hold on;plot([min(xEval) max(xEval)],[.5 .5],'--k','LineWidth',2)
    set(gca,'XTick',(-.5:.2:.5)*2*arcmin);
    set(gca,'ticklength',2*get(gca,'ticklength'))
    set(gca,'LineWidth',2)
    fontSize = 24;
    set(findall(gcf,'type','text'),'fontSize',fontSize); set(gca,'FontSize',fontSize)
    
end