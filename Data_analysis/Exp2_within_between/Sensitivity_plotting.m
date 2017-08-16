clear all;
close all;
load('Sensitivity_results');
%%
figure;
hold on;
subplot(2,2,1);
num_sub=6;
b = bar(sensitivity(1:2,:)',0.8,'EdgeColor','none');
b(1).FaceColor=[0.3 0.3 0.3];
b(2).FaceColor=[0.7 0.7 0.7];
ylabel('PSE (deg)')
Format_graphs;
set(gca,'XTickLabel',{'S1' 'S2' 'S3' 'S4' 'S5' 'S6' });
legend('Central vision','Peripheral vision');

%%
subplot(2,2,3);
h=bar( sensitivity(3,:),0.5,'EdgeColor','none');
set(h,'FaceColor',[0.5 0.5 0.5]);
Format_graphs;
set(gca,'XTickLabel',{'S1' 'S2' 'S3' 'S4' 'S5' 'S6'})
ylabel('Spatial offset (deg)')
%%
hold on;
subplot(2,2,2);
h = bar(sensitivity(4,:),0.5,'EdgeColor','none');
set(h,'FaceColor',[0.5 0.5 0.5]);
ylabel('PSE (deg)')
Format_graphs;
set(gca,'XTickLabel',{'S1' 'S2' 'S3' 'S4' 'S5' 'S6' });
% title('Between hemifields');
%%
subplot(2,2,4);
h = bar(sensitivity(5,:),0.5,'EdgeColor','none');
set(h,'FaceColor',[0.5 0.5 0.5]);
Format_graphs;
set(gca,'XTickLabel',{'S1' 'S2' 'S3' 'S4' 'S5' 'S6'})
ylabel('Eccentricity (deg)')
% title('Between hemifields');