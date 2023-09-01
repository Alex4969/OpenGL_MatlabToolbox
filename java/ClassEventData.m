classdef ClassEventData < event.EventData
   properties
      handle
      mouseEvent
   end
   
   methods
       function data = ClassEventData(handle,mouseEvent)
         data.handle = handle;
         data.mouseEvent = mouseEvent;
      end
   end
end