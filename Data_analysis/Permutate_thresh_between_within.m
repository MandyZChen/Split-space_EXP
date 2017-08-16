

clear all;
close all;
load('Collaped_all_conditions.mat');
Permutated_1 = Permutated_between;
Permutated_2 = Permutated_within;
Collapsed_1 = Collapsed_between;
Collapsed_2 = Collapsed_within;
Permutated.slopes = cell(2,size(Collapsed,2));
Permutated.threshs = cell(2,size(Collapsed,2));
Permutated.threshs_diff = cell(1,size(Collapsed,2));
Permutated.slopes_mean = cell(1,size(Collapsed,2));


%% group level
iteration =5000;
subj_total = size(Collapsed_1.offsets,2);

Permutated.group_real_thresh = nanmean(Permutated_1.real_thresh - Permutated_2.real_thresh);
Permutated.group_real_slopes= nanmean([Collapsed_1.slopeout(1,:) - Collapsed_2.slopeout(1,:), ...
    Collapsed_1.slopeout(2,:) - Collapsed_2.slopeout(2,:)]);

all_thresh_diff=[];
all_slope_mean=[];
for subj = 1:subj_total
    all_thresh_diff = [all_thresh_diff;Permutated_1.threshs_diff{subj}-Permutated_2.threshs_diff{subj}];
    all_slope_mean = [all_slope_mean;Permutated_1.slopes{1,subj} - Permutated_2.slopes{1,subj}];
end

for subj = 1:subj_total
    all_slope_mean = [all_slope_mean;Permutated_1.slopes{2,subj} - Permutated_2.slopes{2,subj}];
end

Permutated.null_thresh_diff =nanmean(all_thresh_diff);
Permutated.null_mean_slope =nanmean(all_slope_mean);
figure;
for subj = 1:subj_total
    subplot(2,4,subj)
    hist(Permutated_1.threshs_diff{subj}-Permutated_2.threshs_diff{subj},100);
    hold on;
    Permutated.real_thresh(subj) = Permutated_1.real_thresh(subj) - Permutated_2.real_thresh(subj);
%     Permutated.real_slope(subj) = (Collapsed.slopeout(2,subj) + Collapsed.slopeout(1,subj))/2;
    plot([Permutated.real_thresh(subj),Permutated.real_thresh(subj)],[0,100],'r','Linewidth',2);
    Permutated.p_value(subj) = sum(abs((Permutated_1.threshs_diff{subj}-Permutated_2.threshs_diff{subj}))>= abs(Permutated.real_thresh(subj)))./iteration;
    Permutated.p_value
end

Permutated.group_p_value_thresh = sum(abs(Permutated.null_thresh_diff)>= abs(Permutated.group_real_thresh))./iteration;
Permutated.group_p_value_slope = sum(abs(Permutated.null_mean_slope)>= abs(Permutated.group_real_slopes))./iteration;
figure;
subplot(1,2,1)
hist(Permutated.null_thresh_diff,100);
hold on;
plot([Permutated.group_real_thresh,Permutated.group_real_thresh],[0,100],'r','Linewidth',2);

subplot(1,2,2)
hist(Permutated.null_mean_slope,100);
hold on;
plot([Permutated.group_real_slopes,Permutated.group_real_slopes],[0,100],'r','Linewidth',2);