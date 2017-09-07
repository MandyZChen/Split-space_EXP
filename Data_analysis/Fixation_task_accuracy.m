%To calculate fixation accuracy

files = uipickfiles('FilterSpec','*.mat');
Accuracy = zeros(1,length(files));
for f = 1:length(files)
    load(files{f});
    num_hit = 0;
    num_miss = 0;
    num_total = 0;
    for i=1:4
        temp_line = history.hitOrMiss(:,:,i);
        num_hit = num_hit+sum(temp_line == 1);
        num_miss = num_miss+sum(temp_line == 0);
    end;
    num_total = num_hit+num_miss;
    Accuracy(f) = num_hit/num_total;
    clear history;
end
Accuracy