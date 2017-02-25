classdef TestGetNumber < mic.Base
        
    properties (Constant)
               
    end
    
	properties
        
        clock
        ui
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
        config                    
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = TestGetNumber()
              
            this.clock = mic.Clock('master');
            cPathConfig = fullfile(...
                mic.Utils.pathConfig(), ...
                'get-set-number', ...
                'config-default-offset.json' ...
            );
            this.config = mic.config.GetSetNumber(cPathConfig);
            
                               
            this.ui = mic.ui.device.GetNumber( ...
                'cName', 'abc', ...
                'clock', this.clock, ...
                'config', this.config, ...
                'dWidthName', 100, ...
                'lShowZero', true, ...
                'lShowRel', true, ...
                'lShowLabels', true, ...
                'lShowApi', true ...
            );  
       
            % For development, set real Api to Apiv
            %{            
            deviceGetNumber = mic.device.GetNumber(...
                'cName', sprintf('%s-real', this.ui.cName), ...
                'clock', this.clock, ...
                'dMean', 5, ...
                'dSig', 0.5 ...
            );
            this.ui.setApi(deviceGetNumber);
            %}
            
        end
                
        function build(this, hParent, dLeft, dTop)
           this.ui.build(hParent, dLeft, dTop); 
        end
        
        function delete(this)
            this.msg('delete', 5);
            delete(this.ui);
            delete(this.clock);
        end
               
    end
    
    methods (Access = protected)
                
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end