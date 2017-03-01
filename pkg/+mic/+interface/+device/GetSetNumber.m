classdef GetSetNumber < mic.Base

    methods (Abstract)
       
       % Retreive the value
       % @return {double 1x1} - the numeric value
       d = get(this)
       
       % Set a new destination and move to it
       % @param {double 1x1} dDest - new destination and move to it
       set(this, dDest) % 
       
       % @return {logical 1x1} - true when stopped or at its target
       l = isReady(this) 
       
       % Stop motion to destination 
       stop(this)
       
       % Take care of any initialization
       initialize(this)
       
       % Ask if any required initialization has been done
       % @return {logical 1x1} 
       l = isInitialized(this)
    end
    
end
        
