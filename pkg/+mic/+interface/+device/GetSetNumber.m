classdef GetSetNumber < mic.Base

    methods (Abstract)
        
       % @return {double 1x1} - the numeric value
       d = get(this) % retrieve value
       
       % @return {logical 1x1} - true when stopped or at its target
       l = isReady(this) 
       
       % Set a new destination and move to it
       % @param {double 1x1} dDest - new destination and move to it
       set(this, dDest) % 
       
       % Stop motion to destination 
       stop(this)
       
       % Take care of any initialization
       initialize(this)
       
       % @return {logical 1x1} 
       l = isInitialized(this)
    end
    
end
        
