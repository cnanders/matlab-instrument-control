classdef GetLogical < mic.Base

    methods (Abstract)
        
       % Get the value
       % @return {logical 1x1}
       l = get(this)
       
       % Command the device to initialize.
       initialize(this)
       
       % @return {logical 1x1} 
       l = isInitialized(this)
        
    end
    
end
        
