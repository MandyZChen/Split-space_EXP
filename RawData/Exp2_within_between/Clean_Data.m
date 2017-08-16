addpath('/Users/mandychan/Documents/Unifying-space-Experiments/CommonFunctions/');
%%
clear all;
close  all;
files = dir('*.mat');

%%
for i = 1:length(files)
   load(files(i).name);
   History =[];
   History.response = history.response;
   History.offset = history.offset;
   History.hitOrMiss = history.hitOrMiss;
   save(files(i).name, 'History');
end