clear all;

%% Putting in data

% For movie
subject_name_file = {'S1','S2','S3','S4','S5'};
subject_name = subject_name_file;

num_sub = length(subject_name_file);
for i=1:num_sub
    load([subject_name_file{i},'_' ,'movie', '.mat']);
end;

%% SECTION TITLE
% DESCRIPTIVE TEXT

threshOut=[];
diffBoot=[];
for i = 1:num_sub
eval(['threshOut = [threshOut;threshOut_',subject_name{i},'];']);
eval(['diffBoot = [diffBoot, diff(bootThreshOut_',subject_name{i},',1,2)','];']);
end

%% threshold raw
threshOut=threshOut';

fontSize = 18;
threshDiff = diff(threshOut);

threshDiff = [threshDiff mean(threshDiff)];
%% Bootstrap data
diffBoot = squeeze(diffBoot)';

diffBoot = [diffBoot;mean(diffBoot)];
CI = 1.96*std(diffBoot,[],2); 

%% Ploting
figure;
hold on;
subplot(2,2,1:2);
b = bar(threshOut',0.8,'EdgeColor','none');
b(1).FaceColor=[0 0 0.7];
b(2).FaceColor=[0.7 0 0];
ylabel('PSE (deg)')
Format_graphs;
set(gca,'XTickLabel',{'S1' 'S2' 'S3' 'S4' 'S5'});
title('Vertical meridian');
%title('Up/down occluder');
%%
subplot(2,2,3:4);
h=bar([1:num_sub,num_sub+2], threshDiff,0.8,'EdgeColor','none');
set(h,'FaceColor',[0 .5 0]);
hold on;
errorbar([1:num_sub num_sub+2],threshDiff,CI,CI,'k','LineStyle','none','LineWidth',2)
Format_graphs;
set(gca,'XTickLabel',{'S1' 'S2' 'S3' 'S4' 'S5' 'Avg'})
ylabel('Diff of PSEs (deg)')
title('Vertical meridian');