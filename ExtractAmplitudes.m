%% Extract amplitude averages over electrodes and time bins per participant

Average = zeros(27,2);
for i = 1:27
   Average[i,1] = subjects(i);
   extract = mean(Condition1{i}.avg([13,40,42,43,44,39],[351:451]));
   average = mean(extract);
   Averages[i,2] = mean(average);
   extract2 = mean(Condition2{i}.avg([13,40,42,43,44,39], [351:451]));
   average2 = mean(extract2);
   Averages[i,3] = mean(average2);
end
