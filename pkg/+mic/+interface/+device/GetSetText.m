classdef GetSetText < mic.Base

    methods (Abstract)
        
       c = get(this) % retrieve value
       set(this, cVal) % set new value
       
       % Command the device to initialize.
       initialize(this)
       
       % @return {logical 1x1} 
       l = isInitialized(this)
        
    end
    
end
        
