addpath('/Users/mandychan/Documents/Unifying-space-Experiments/CommonFunctions/');
clearvars -except Collapsed*
close all;
%% To use this script, please specify the number of subjects you are going to combine.
% The program will prompt an interface for your to add every subjects and
% their data for the two conditions respectively. Please select all the
% files for config 1 for one subject and then config 2. After feeding in data
% for all conditions, you can proceed to the next subject.
subj_num_total = 8;
file_type = '*.mat'; % restrict the file type displaying on the interface

%%
for subj_num =1:subj_num_total
    plotCols = {'b' 'r' 'b' 'r'};
    arcmin = 1;
    figure;
    nConds = 2;
    boot_iteration = 1000;
    
    for c = 1:nConds
        
        files = uipickfiles('FilterSpec',file_type);
        for f = 1:length(files)
            load(files{f});
            eval(['history_' num2str(f) '= history;']);
            eval(['params_' num2str(f) '= params;']);
        end
        
        subject_name = params.subjID;
        
        clear history;
        
        if length(files) == 1
            history.offset = history_1.offset;
            history.response = history_1.response;
        elseif length(files) == 2
            history.offset = [history_1.offset, history_2.offset];
            history.response = [history_1.response history_2.response];
        elseif length(files) ==4
            history.offset = [history_1.offset, history_2.offset,history_3.offset,history_4.offset];
            history.response = [history_1.response,history_2.response,history_3.response,history_4.response];
        end
        
        params.allTrials = [];
        for f = 1:length(files)
            eval(['params.allTrials = [params.allTrials params_' num2str(f) '.allTrials];']);
        end
        
        relevantTrials = true(1,length(history.offset));
        
        if params.merConfig ==1
            relResp =  history.response(relevantTrials)'== -1;
            relOffsets  = -2*arcmin* history.offset(relevantTrials);%multiplied by 2 to get full vernier offset
        else
            relOffsets  = 2*arcmin* history.offset(relevantTrials);%multiplied by 2 to get full vernier offset
            relResp =  history.response(relevantTrials)'==1;
        end
        
        [a b boot_params,b_boot_std] = j_fit_ak(relOffsets'-min(relOffsets), relResp,'logistic1',boot_iteration);
        % a is the slope
        b = b+min(relOffsets); % b is the threshold
        boot_params(:,2) = boot_params(:,2)+min(relOffsets);
        [xVals(c,:) percResp(c,:)] = percent_corr(relOffsets', relResp);
        hold on;scatter(xVals(c,:),percResp(c,:),700,['.' plotCols{c}]);
        xEval = min(history.offset*arcmin*2):.01:max(history.offset*arcmin*2);
        scale = 1;shift =0;
        yEval = scale./(1+exp(-a*(xEval-b)))+shift;
        hold on;h(c) = plot(xEval,yEval,plotCols{c},'LineWidth',2);
        threshOut(c) = b;
        bootThreshCI(c)=1.96*b_boot_std;
        bootThreshOut(:,:,c) = boot_params(:,2);
        
        Collapsed.offsets{c,subj_num} = history.offset;
        Collapsed.response{c,subj_num} = history.response;
        Collapsed.threshout(c,subj_num) = b;
        Collapsed.slopeout(c,subj_num) = a;
        Collapsed.bootThreshOut{c,subj_num} = bootThreshOut;
        Collapsed.bootThreshCI{c,subj_num} = bootThreshCI;
        Collapsed.boot_params{c,subj_num} = boot_params;
        Collapsed.subjName{c,subj_num} = subject_name;
    end
    
    set(gcf,'Position',[70   120   635   564])
    
    legendLabels = {'config 1' 'config 2'};
    
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
end
