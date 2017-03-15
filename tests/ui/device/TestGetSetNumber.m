classdef TestGetSetNumber < mic.Base
        
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
        
        
        function this = TestGetSetNumber()
              
            this.clock = mic.Clock('master');   

            cPathConfig = fullfile(...
                mic.Utils.pathConfig(), ...
                'get-set-number', ...
                'config-mono.json' ... % 'config-default-offset.json' ...
            );

            this.config = mic.config.GetSetNumber('cPath', cPathConfig);
                            
            this.ui = mic.ui.device.GetSetNumber(...
                'cName', 'abc', ...
                'cLabel', 'abc', ...
                'clock', this.clock, ...
                'config', this.config, ...
                'lShowStores', true, ...
                'lShowUnit', true, ...
                'lShowInitButton', true, ...
                'lShowInitState', false, ...
                'lShowRange', true, ...
                'cConversion' , 'e', ... % exponential notaion
                'fhValidateDest', @this.validateDest ...
            );
            %  this.ui = HardwareIOPlus();
       
            % For development, set real Api to virtual
            %{
            cName = sprintf('%s-real', this.ui.cName);
            apiv = mic.device.GetSetNumberVirtual(cName, 0, this.clock);
            this.ui.setApi(apiv);
            %}
            
        end
        
        function lOut = validateDest(this)
            
            % Implement this however you want
            
            lOut = true;
            return
            
            if this.ui.getValRaw() > this.config.dMax || ...
               this.ui.getValRaw() < this.config.dMin
                           
                
                cMsg = sprintf(...
                    'The destination %1.*f %s ABS (%1.*f %s REL) is now allowed.', ...
                    this.ui.getUnit().precision, ...
                    this.ui.getDestCal(this.ui.getUnit().name), ...
                    this.ui.getUnit().name, ...
                    this.ui.getUnit().precision, ...
                    this.ui.getDestCalDisplay(), ...
                    this.ui.getUnit().name ...
                );
                cTitle = sprintf('Position not allowed');
                msgbox(cMsg, cTitle, 'warn')
                
                                
                
                lOut = false;
            else 
                lOut = true;
            end
        end
        
        function build(this, hParent, dLeft, dTop)
           this.ui.build(hParent, dLeft, dTop); 
        end
        
        function delete(this)
            this.msg('delete()');
            
            delete(this.ui);
            delete(this.clock);
        end
               
    end
    
    methods (Access = protected)
                
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end