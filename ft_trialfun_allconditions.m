function [trl, event] = ft_trialfun_allconditions(cfg)

% read the header information and the events from the data
% this should always be done using the generic read_header
% and read_event functions
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

trl = [];

markers = cfg.markers;

% select only the good trials
for j = 1:(length(value))
  trg1 = value(j);
  if strcmp(trg1, markers{1}) || strcmp(trg1, markers{2})
    trlbegin = sample(j) + pretrig;       
    trlend   = sample(j) + posttrig;       
    offset   = pretrig;
    newtrl   = [trlbegin trlend offset];
    trl      = [trl; newtrl];
  end
end