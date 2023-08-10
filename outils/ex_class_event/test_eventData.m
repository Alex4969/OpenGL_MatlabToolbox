

evtdata = ClassEventData('111');
evtdata.otherData=222;

m = myClass();

m.sendEvent(evtdata);

% notify(obj,'ToggledState',evtdata);