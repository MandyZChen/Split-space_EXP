clearvars -except Collapsed* Permutated*
close all;
% load('Collapsed_movieGlass');
Collapsed = Collapsed_between;
iteration = 5000;
merConfig =1;
arcmin = 1;
Permutated.slopes = cell(2,size(Collapsed,2));
Permutated.threshs = cell(2,size(Collapsed,2));
Permutated.threshs_diff = cell(1,size(Collapsed,2));
Permutated.slopes_mean = cell(1,size(Collapsed,2));

%%
subj_total = size(Collapsed.offsets,2);
for subj = 1:subj_total
    
    real_dis.offset = [Collapsed.offsets{1,subj},Collapsed.offsets{2,subj}];
    real_dis.response = [Collapsed.response{1,subj},Collapsed.response{2,subj}];
    real_dis.num = length(Collapsed.offsets{1,subj})+length(Collapsed.offsets{2,subj});
    Permutated.slopes{1,subj} =[];
    Permutated.slopes{2,subj} =[];
    Permutated.threshs{1,subj} =[];
    Permutated.threshs{2,subj} =[];
    Permutated.threshs_diff{1,subj} =[];
    Permutated.slopes_mean{1,subj} =[];

    for iter = 1:iteration
        
        if mod(iter, 1000) == 0
            iter
        end
        
        rand_1 = randperm(real_dis.num ,length(Collapsed.offsets{1,subj}));
        rand_2 = setdiff(1:real_dis.num ,rand_1);
        Permutated_offset_1 = real_dis.offset(rand_1);
        Permutated_response_1 = real_dis.response(rand_1);
        Permutated_offset_2 = real_dis.offset(rand_2);
        Permutated_response_2 = real_dis.response(rand_2);
        
        relevantTrials = 1:(real_dis.num/2);
        
        if merConfig == 1
            relResp_1 =  Permutated_response_1(relevantTrials)'== -1;
            relOffsets_1  = -2*arcmin* Permutated_offset_1(relevantTrials);%multiplied by 2 to get full vernier offset
            relResp_2 =  Permutated_response_2(relevantTrials)'== -1;
            relOffsets_2  = -2*arcmin* Permutated_offset_2(relevantTrials);%multiplied by 2 to get full vernier offset
 
        else
            relOffsets_1  = 2*arcmin* Permutated_offset_1(relevantTrials);%multiplied by 2 to get full vernier offset
            relResp_1 =  Permutated_response_1(relevantTrials)'==1;
            relOffsets_2  = 2*arcmin* Permutated_offset_2(relevantTrials);%multiplied by 2 to get full vernier offset
            relResp_2 =  Permutated_response_2(relevantTrials)'==1;
        end
        
        [slope_1 thresh_1] = j_fit_ak(relOffsets_1'-min(relOffsets_1), relResp_1,'logistic1',0);
        thresh_1 = thresh_1+min(relOffsets_1);
        [slope_2 thresh_2] = j_fit_ak(relOffsets_2'-min(relOffsets_2), relResp_2,'logistic1',0);
        thresh_2 = thresh_2+min(relOffsets_2);
        Permutated.slopes{1,subj} = [Permutated.slopes{1,subj}, slope_1];
        Permutated.slopes{2,subj} = [Permutated.slopes{2,subj}, slope_2];
        Permutated.threshs{1,subj} = [Permutated.threshs{1,subj}, thresh_1];
        Permutated.threshs{2,subj} = [Permutated.threshs{2,subj}, thresh_2];
        Permutated.threshs_diff{1,subj} = [Permutated.threshs_diff{1,subj}, thresh_2-thresh_1];
        Permutated.slopes_mean{1,subj} = [Permutated.slopes_mean{1,subj}, (slope_2+slope_1)/2];
    end 
    
    subplot(2,4,subj)
    hist(Permutated.threshs_diff{1,subj},100);
    hold on;
    Permutated.real_thresh(subj) = Collapsed.threshout(2,subj) - Collapsed.threshout(1,subj);
    Permutated.real_slope(subj) = (Collapsed.slopeout(2,subj) + Collapsed.slopeout(1,subj))/2;

    plot([Permutated.real_thresh(subj),Permutated.real_thresh(subj)],[0,100],'r','Linewidth',2);
    Permutated.p_value(subj) = sum(abs(Permutated.threshs_diff{1,subj})>= abs(Permutated.real_thresh(subj)))./iteration;
    Permutated.p_value
end

%% group level
all_thresh_diff=[];
all_slope_mean=[];
for subj = 1:subj_total
    all_thresh_diff = [all_thresh_diff;Permutated.threshs_diff{1,subj}];
    all_slope_mean = [all_slope_mean;Permutated.slopes_mean{1,subj}];
end
Permutated.group_real_thresh = nanmean(Permutated.real_thresh);
Permutated.mean_thresh_diff =nanmean(all_thresh_diff);

Permutated.group_real_slope = nanmean(Permutated.real_slope);
Permutated.mean_slope =nanmean(all_slope_mean);

Permutated.group_p_value = sum(abs(Permutated.mean_thresh_diff)>= abs(Permutated.group_real_thresh))./iteration;
Permutated.group_p_value_slope = sum(abs(Permutated.mean_slope)<= 0)./iteration;

subplot(1,2,1)
hist(Permutated.mean_thresh_diff,100);
hold on;
plot([Permutated.group_real_thresh,Permutated.group_real_thresh],[0,100],'r','Linewidth',2);

subplot(1,2,2)
hist(Permutated.mean_slope,100);
hold on;
plot([Permutated.group_real_slope,Permutated.group_real_slope],[0,100],'r','Linewidth',2);