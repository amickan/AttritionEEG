%% Extract amplitude averages over electrodes and time bins per participant

Average = zeros(27,2);
for i = 1:27
   extract = mean(Condition1{i}.avg([13,40,42,43,44,39],[351:451]));
   average = mean(extract);
   Averages[i,1] = mean(average);
   extract2 = mean(Condition2{i}.avg([13,40,42,43,44,39], [351:451]));
   average2 = mean(extract2);
   Averages[i,2] = mean(average2);
end
