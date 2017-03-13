classdef GetSetText < mic.Base

    methods (Abstract)
        
       % @return {char 1xm} the value 
       c = get(this)
       
       % @param {char 1xm} cVal - the new value
       set(this, cVal)
       
       % Take care of any initialization
       initialize(this)
       
       % @return {logical 1x1} 
       l = isInitialized(this)
        
    end
    
end
        
