function [trl, event] = correctonly_trialfun(cfg);

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% search for "stimulus" events
for i =1:length(event)
    value{i} = [event(i).value];
end;
%value  = [event(find(strcmp('Stimulus', {event.type}))).value]';
sample = [event.sample]';

% determine the number of samples before and after the trigger
pretrig  = -round(cfg.trialdef.prestim  * hdr.Fs);
posttrig =  round(cfg.trialdef.poststim * hdr.Fs);

% determine the stimulus event values
marker1 = cfg.marker1;
marker2 = cfg.marker2;

% look for the combination of a trigger "7" followed by a trigger "64" 
% for each trigger except the last one
trl = [];
for j = 1:(length(value)-2)
  trg1 = value(j);
  trg2 = value(j+2);
  if strcmp(trg1,marker1) && strcmp(trg2,marker2)
    trlbegin = sample(j) + pretrig;       
    trlend   = sample(j) + posttrig;       
    offset   = pretrig;
    newtrl   = [trlbegin trlend offset];
    trl      = [trl; newtrl];
  end
end