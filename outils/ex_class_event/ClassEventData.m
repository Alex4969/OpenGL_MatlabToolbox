classdef ClassEventData < event.EventData
   properties
      NewState
      otherData
   end
   
   methods
      function data = ClassEventData(newState)
         data.NewState = newState;
      end
   end
end