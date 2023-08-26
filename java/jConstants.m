classdef jConstants
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties (Constant)
        BORDERLAYOUT struct=struct('CENTER',"Center",'SOUTH',"South",'NORTH',"North",'EAST',"East",'WEST',"West");
        FRAME_CLOSE_OPERATION struct=struct('DISPOSE_ON_CLOSE',2, 'DO_NOTHING_ON_CLOSE',0, 'HIDE_ON_CLOSE' ,1, 'EXIT_ON_CLOSE',3)
    end

    methods
        function obj = jConstants
        
        end


    end

    methods(Static)
        function r=BORDERLAYOUT_Constant
            jc=jConstants;
            r=jc.BORDERLAYOUT;
        end

        function r=FRAME_CLOSE_OPERATION_Constant
            jc=jConstants;
            r=jc.FRAME_CLOSE_OPERATION;
        end    
    
    end
end