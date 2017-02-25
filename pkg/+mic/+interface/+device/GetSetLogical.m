classdef GetSetLogical < mic.Base

    methods (Abstract)
        
       % Get the value
       % @return {logical 1x1}
       l = get(this)
       
       % Set the value
       % @param {logical 1x1} lVal
       set(this, lVal)
       
       % Command the device to initialize.
       initialize(this)
       
       % @return {logical 1x1} 
       l = isInitialized(this)
        
    end
    
end
        
