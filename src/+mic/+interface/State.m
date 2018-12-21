classdef State < mic.Base

    methods (Abstract)
        
        % invokes any motors that need to move to get sensors to read desired value +/- tolerance
        go(this)
        
        % stops any motors invoked by go
        stop(this)
       
        % returns true when any motors invoked by go() are moving
        % @return {logical 1x1}
        l = isGoing(this)
       
        % returns true when all sensors read desired value +/- tolerance
        % @return {logical 1x1} 
        l = isThere(this)
        
    end
    
end
        
