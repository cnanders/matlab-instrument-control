classdef Checkbox < mic.interface.ui.common.Logical & mic.ui.common.Base
    
%     properties (Constant)
%         dHeight = 15;
%     end
    
    properties
        
        
    end
    
    
    properties (Access = private)
        lChecked = false
        cLabel = 'Fix Me'
        lShowLabel = true
        fhDirectCallback
        
        dColor = 'white'
    end
    
    
    events
      eChange  
    end
    
    
    methods
        
       % Constructor
       function this = Checkbox(varargin)
            
           this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
           
           this.hUI = uicontrol( ...
                ...
                'Parent',           hParent, ...
                'BackgroundColor',  this.dColor, ...
                'Position',         mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style',            'checkbox', ...
                'Callback',         @this.onCheckbox, ...
                'Value',            this.lChecked, ...
                'String',           this.cLabel ...
            );
        
       end
       

       % Callback
       function onCheckbox(this, src, evt)
           this.lChecked = logical(get(src, 'Value'));
           this.fhDirectCallback();
       end
       
       function l = get(this)
           l = this.lChecked;
       end
       
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

        % @return {struct} state to save
        function st = save(this)
            st = struct();
            st.lChecked = this.lChecked;
        end
        
        % @param {struct} state to load
        function load(this, st)
            this.set(st.lChecked);
        end
       
       
       
               
    end
end