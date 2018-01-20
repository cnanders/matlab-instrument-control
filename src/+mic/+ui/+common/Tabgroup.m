classdef Tabgroup < mic.Base
    
    
    properties (Constant)
        
    end
    
    
    properties (SetAccess = private)
        
        
    end
    
    
    properties (Access = protected)
        
        dLeft
        dTop
        dWidth
        dHeight
        
        hParent
        hLabel
        hUI
        
        ceTabNames
        uitTabs
        
        % {logical}
        lIsBuilt = false;
        
        % {function_handle 1x1} callback when user presses up, down, or X
        fhDirectCallback = {@()[]};
        
        % {uint8 1} selected tab index
        u8Selected
        
        
    end
    
    
    
    methods
        
        % constructor
        
        
        function this = Tabgroup(varargin)
            
            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
        end
        
        
       
        
        function uitTab = getTabByName(this, cName)
            uitTab = this.getTabByIndex(strcmp(this.ceTabNames, cName));
        end
        
        function uitTab = getTabByIndex(this, dIndex)
            uitTab = this.uitTabs{dIndex};
        end
        
        function onSelectionChange(this, src, evt)
            cNewTabName = evt.NewValue.Title;
            
            % get new tab index:
            dIdx = find(strcmp(this.ceTabNames, cNewTabName));
            
            % Call callback associated with this tab:
            if length(this.fhDirectCallback) >= dIdx
                this.fhDirectCallback{dIdx}();
            end
            
            
        end
    
        
        % Builds the UI elements
        function build(this,  hParent,  dLeft, dBot,  dWidth,  dHeight ...
                )
            
            
            this.hUI = uitabgroup( ...
                'Parent', hParent, ...
                'Unit', 'pixels', ...
                'Position', [dLeft, dBot, dWidth, dHeight], ...
                'SelectionChangedFcn', @this.onSelectionChange ...
                );
            
            for k = 1:length(this.ceTabNames)
                cTabname = this.ceTabNames{k};
                
                this.uitTabs{k} = uitab('parent', this.hUI, ...
                                        'title', cTabname, ...
                                        'Unit', 'pixels');
            end
            
            
        end
        
       
        
        
        
        
    end
    
    methods (Access = protected)
        
        
        
        
        
        
    end
end