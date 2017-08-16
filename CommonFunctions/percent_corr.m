 
    function [x_adjusted y_adjusted] = percent_corr(x, y)
    %convert to proportion correct if the data consists of only 2 possible
    %values (correct/incorrect).    
 
            x_set = unique(x);
            y_set = zeros(length(x_set),1);
            for i = 1:length(x_set);
                y_set(i) = mean(y(x == x_set(i))); %compute proportion correct at each unique level of x
            end
            x_adjusted = x_set;
            y_adjusted = y_set;

    end