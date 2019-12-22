function f = time2stim(Params,t)
 f = round(t./(Params.timeline.mask + Params.timeline.stimulus));
end