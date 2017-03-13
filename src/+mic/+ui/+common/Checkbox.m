classdef Checkbox < mic.interface.ui.common.Logical & mic.ui.common.Base
    
%     properties (Constant)
%         dHeight = 15;
%     end
    
    properties
        
        
    end
    
    
    properties (Access = private)
        hLabel
        lChecked = false
        cLabel = 'Fix Me'
        lShowLabel = true
    end
    
    
    events
      eChange  
    end
    
    
    methods
        
       % Constructor
       function this = Checkbox(varargin)
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
           
           this.hUI = uicontrol( ...
                ...
                'Parent',           hParent, ...
                'BackgroundColor',  'white', ...
                'Position',         mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style',            'checkbox', ...
                'Callback',         @this.cb, ...
                'Value',            this.lChecked, ...
                'String',           this.cLabel ...
            );
        
       end
       

       % Callback
       function cb(this, src, evt)
           this.lChecked = logical(get(src, 'Value'));
       end
       
       function l = get(this)
           l = this.lChecked;
       end
       
       % Modifiers
       function set(this, lChecked)
           
           % Rules
           if islogical(lChecked)
               this.lChecked = lChecked;
           elseif any(lChecked == [0, 1])
               this.lChecked = logical(lChecked);
           end
           
           % ui
           if ~isempty(this.hUI)
               set(this.hUI, 'Value', this.lChecked);
           end
           
           notify(this,'eChange');
               
       end
       
       
       
               
    end
end