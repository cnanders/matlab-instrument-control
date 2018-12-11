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
        
        % {cell array of function_handle 1xm} one for each item in
        % ceTabNames
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
        
        
        function cName = getSelectedTabName(this)
            uitSelectedTab = this.hUI.SelectedTab;
            cName = uitSelectedTab.Title;
        end
        
        function selectTabByName(this, cName)
            uitTab = this.getTabByName(cName);
            this.hUI.SelectedTab = uitTab;
        end
        
        function selectTabByIndex(this, dIndex)
            uitTab = this.getTabByIndex(dIndex);
            this.hUI.SelectedTab = uitTab;
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
        
        function l = doesTabExist(this, cTabname)
            dIdx = find(strcmp(this.ceTabNames, cTabname));
            l = ~isempty(dIdx);
        end
        
        function uiTab = addTab(this, cTabname)
            uiTab = uitab('parent', this.hUI, ...
                                        'title', cTabname, ...
                                        'Unit', 'pixels');
            this.uitTabs{end + 1} = uiTab;
            this.ceTabNames{end + 1} = cTabname;
        end
        
        function removeTab(this, cTabname)
            hTab = this.getTabByName(cTabname);
            
            if (isa(hTab, 'handle'))
                dIdx = find(strcmp(this.ceTabNames, cTabname));
                
                this.uitTabs(dIdx) = [];
                this.ceTabNames(dIdx) = [];
                delete(hTab);
            end
        end
        
        function alphabetizeTabs(this)
            if length(this.ceTabNames) < 2
                return
            end
            
            
            [this.ceTabNames, idx] = sort(this.ceTabNames);
            
            % Use idx to sort tabs and tabgroup children:
            this.uitTabs = this.uitTabs(idx);
            this.hUI.Children = this.hUI.Children(idx);
        end
    
        
        % Builds the UI elements
        function build(this,  hParent,  dLeft, dTop,  dWidth,  dHeight ...
                )
            
            
            this.hUI = uitabgroup( ...
                'Parent', hParent, ...
                'Unit', 'pixels', ...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
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