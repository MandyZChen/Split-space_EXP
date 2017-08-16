clear all;close all;

%% Putting in data

% load bar_4_poster_glass.mat
subject_name = {'BW','AK','MC'};
condition_name = {'symCircle','symRandom','asymCircle'};
variable_name = {'sc','sr','ac'};
num_sub = length(subject_name);
for i=1:num_sub
    for j=1:length(condition_name)
    load([subject_name{i},'_' ,condition_name{j}, '.mat']);
    load([subject_name{i},'_' ,condition_name{j}, '.mat']);
    end
end

%% SECTION TITLE
% DESCRIPTIVE TEXT

for i=1:length(condition_name)
    eval(['threshOut_',variable_name{i},'=[];']);
    eval(['diffBoot_',variable_name{i},'=[];']);
end

%%
for i = 1:num_sub
    for j=1:length(variable_name)
        eval(['threshOut_' variable_name{j} '= [threshOut_' variable_name{j} ';threshOut_',subject_name{i},variable_name{j},'];']);
        eval(['diffBoot_' variable_name{j} '= [diffBoot_' variable_name{j} ', diff(bootThreshOut_' subject_name{i} variable_name{j} ',1,2)','];']);
    end
end

%% threshold raw

threshOut_sc=threshOut_sc';
threshOut_sr=threshOut_sr';
threshOut_ac=threshOut_ac';

%%
fontSize = 18;
threshDiff_sc = diff(threshOut_sc);
threshDiff_sr = diff(threshOut_sr);
threshDiff_ac = diff(threshOut_ac);

threshDiff_diff_s = threshDiff_sc-threshDiff_ac;
threshDiff_diff_s =[threshDiff_diff_s 0  mean(threshDiff_diff_s)];
threshDiff_diff_c = threshDiff_sc-threshDiff_sr;
threshDiff_diff_c =[threshDiff_diff_c 0 mean(threshDiff_diff_c)];

threshDiff_sc = [threshDiff_sc 0 mean(threshDiff_sc)];
threshDiff_sr = [threshDiff_sr 0 mean(threshDiff_sr)];
threshDiff_ac = [threshDiff_ac 0 mean(threshDiff_ac)];

%% Bootstrap data
diffBoot_sc = squeeze(diffBoot_sc)';
diffBoot_sr = squeeze(diffBoot_sr)';
diffBoot_ac = squeeze(diffBoot_ac)';

diffBoot_diff_s = diffBoot_sc-diffBoot_ac;
diffBoot_diff_s = [diffBoot_diff_s; zeros(1,1000);mean(diffBoot_diff_s)];

CI_diff_s = 1.96*std(diffBoot_diff_s,[],2);

diffBoot_diff_c = diffBoot_sc-diffBoot_sr;
diffBoot_diff_c = [diffBoot_diff_c;zeros(1,1000);mean(diffBoot_diff_c)];

CI_diff_c = 1.96*std(diffBoot_diff_c,[],2);

diffBoot_sc = [diffBoot_sc;zeros(1,1000); mean(diffBoot_sc)];
CI_sc = 1.96*std(diffBoot_sc,[],2);

diffBoot_sr = [diffBoot_sr;zeros(1,1000);mean(diffBoot_sr)];
CI_sr = 1.96*std(diffBoot_sr,[],2);

diffBoot_ac = [diffBoot_ac; zeros(1,1000);mean(diffBoot_ac)];
CI_ac = 1.96*std(diffBoot_ac,[],2);

%% Ploting
% figure;
% hold on;
% subplot(3,2,1);
% b = bar([threshOut_sc',0.8,'EdgeColor','none');
% b(1).FaceColor=[0 0 0.7];
% b(2).FaceColor=[0.7 0 0];
% ylabel('PSE (deg)')
% Format_graphs;
% set(gca,'XTickLabel',{'S1' 'S2' 'S3' 'S4' 'S5','S6','S7','S8'});
% title('Vertical meridian');
% %title('Up/down occluder');
%%
errorbar_groups([threshDiff_sc',threshDiff_sr',threshDiff_ac'],[CI_sc,CI_sr,CI_ac],'bar_width',0.5, ...
    'errorbar_width',0.9,'bar_colors',[0.8,0,0;0,0.8,0;0,0,0.8;0.5,0.5,0.5;0.5,0.5,0.5],'bar_names',{'S1','S2','S3',' ','Avg'});
Format_graphs;
set(gca,'XTickLabel',{'Symmetry&Circular' 'Symmetry&Random' 'Asymmetry&Circular'})
ylabel('Diff of PSEs (deg)')
% title('Vertical meridian');

%%
errorbar_groups([threshDiff_diff_s',threshDiff_diff_c'],[CI_diff_s,CI_diff_c],'bar_width',0.5, ...
    'errorbar_width',0.9,'bar_colors',[0.8,0,0;0,0.8,0;0,0,0.8;0.5,0.5,0.5;0.5,0.5,0.5],'bar_names',{'S1','S2','S3',' ','Avg'});
Format_graphs;
set(gca,'XTickLabel',{'Symmetry - Asymmetry' 'Circular-random'})
ylabel('Diff of PSEs (deg)')
% title('Vertical meridian');

