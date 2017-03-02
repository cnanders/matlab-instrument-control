classdef   GetSetLogical < mic.interface.ui.device.Base
    
    %GETSETNUMBER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Abstract)
        
        % Return the value of device.get()
        % @return {logical 1x1} 
        l = get(this)
        
        % Programatic equivalent of pressing the command toggle to a given
        % state. Subsequently calls device.set()
        % @param {logical 1x1} l - commanded state
        set(this, l)
        
  
    end
    
end

