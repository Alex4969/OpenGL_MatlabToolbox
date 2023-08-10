classdef myClass < handle
   properties
      
   end

   events
       myEvent
   end
   methods
      function obj = myClass()
         hl = addlistener(obj,'myEvent',@obj.cbk_handleEvnt);
         % obj.ListenerHandle = hl; % Save listener handle
      end

      function sendEvent(obj,eventData)
          notify(obj,'myEvent',eventData)
      end

      function cbk_handleEvnt(obj,src,event)
            disp('le callback est appelé')
            disp(['data 1 = ' event.NewState])
            disp(['data 2 = ' num2str(event.otherData)])
      end
   end
end