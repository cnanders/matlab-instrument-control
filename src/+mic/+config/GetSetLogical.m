classdef GetSetLogical < mic.Base
        
    properties (Constant)
               
    end
    
	properties
        
        
        
    end
    
    properties (SetAccess = private)
        dDelay   % @prop {double} dDelay - the delay in seconds for UI updates
    end
    
    properties (Access = private)
       % @prop {char 1xm} - path to a JSON configuration file
       cPath = fullfile(...
            mic.Utils.pathConfig(), ...
            'get-set-logical', ...
            'default.json' ...
       );         
       stJson   % @prop {struct} stJson - struct representation of JSON (returned by parse_json) 
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = GetSetLogical(varargin)
        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if (exist(this.cPath, 'file') ~= 2) 
                
                exception = MException(...
                    'Config:cPath', ...
                    sprintf('The config file: %s does not exist', this.cPath) ...
                );
                throw(exception);
            else 
               this.msg(...
                    sprintf('loading config file: %s', this.cPath), ...
                    3 ...
               );     
            end
            
            
            this.stJson = parse_json(fileread(this.cPath));
            this.stJson = this.stJson{1}; % has to do with parse_json

              
            if ~this.validateJson()
                return;
            end
            
            % delay is requires
            this.dDelay = this.stJson.delay;
            
        end
        
        
        
        
    end
    
    methods (Access = protected)
        function lOut = validateJson(this)
        %VALIDATE Validate a configuration structure.  These are JSON
        %files that are loaded and parsed with parse_json function to
        %become a struct
        
        
            fields = {'delay'};
            for n = 1:length(fields)
                if ~isfield(this.stJson, fields{n})
                    msg = sprintf(...
                        'Invalid config file. Must contain property "%s"', ...
                        fields{n} ...
                    );
                    this.msg(msg, 2);
                    lOut = false;
                    return;
                end
            end
            
            
            lOut = true;
        end      
       
        
    end
    
    methods (Access = private)
        
        
        
    end 
    
    
end