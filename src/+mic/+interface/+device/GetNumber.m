classdef GetNumber < mic.Base

    methods (Abstract)
        
       % @return {double 1x1} - the numeric value
       d = get(this)
       
       
       % Take care of any initialization
       initialize(this)
       
       % @return {logical 1x1} 
       l = isInitialized(this)
        
    end
    
end
        
