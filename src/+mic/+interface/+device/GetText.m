classdef GetText < mic.Base

    methods (Abstract)
        
       % @return {char 1xm} - the text value
       c = get(this) 
       
       % Command the device to initialize.
       initialize(this)
       
       % @return {logical 1x1} 
       l = isInitialized(this)
        
    end
    
end
        
