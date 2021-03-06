classdef GetSetText < mic.interface.ui.device.Base
    
    %GETSETNUMBER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Abstract)
        
        % Return the value of device.get()
        % @return {char 1xm} 
        c = get(this)
        
        % Return the value of mic.ui.common.Edit.get()
        % @return {char 1xm} 
        c = getDest(this)
        
        
        % Call mic.ui.common.Edit.set() with a value
        % @param {char 1xm} cVal - the new destination
        setDest(this, cVal)
        
        % Call device.set() passing mic.ui.common.Edit.get()
        moveToDest(this)

        % @return {struct 1x1} the state to save
        st = save(this)

        % @para {struct 1x1} st - the state to load (must match signature
        % returned by save)
        load(this, st)
                
  
    end
    
end

