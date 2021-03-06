classdef ListDir < mic.ui.common.List
    
    % TO DO
    % Update with proper interface
    
    properties (Constant)
       
    end
    
      
    properties (SetAccess = private)
        
                   
    end
    
    
    properties (Access = protected)
        
       % {char 1xm} - full path to the directory
        cDir 
        
        % {char 1xm} - filter for dir2cell, e.g., '*.json'
        cFilter = '*'
        
        % {mic.ui.common.Button 1x1}
        uiButtonChooseDir
        
        % {mic.ui.common.Text 1x1}
        uiTextDir
        
        % {logical 1x1} - show the "choose dir" button
        lShowChooseDir = true
        
        cOrderByPredicate = 'date'
        lOrderByReverse = false
        
        hPanel
        
        % { char 1xm} title of the panel
        cTitle
        
        fhOnChangeDir = @(src, evt)[];
    end
    
    properties (Access = private)
        
        
        dColorOfPanelBackground = [.4 .4 0];
        
                   
    end
    
    
    events
        
        % NOTE THIS EXTENDS mic.common.ui.List and has all events from 
        % mic.common.ui.List
    end
    
    
    methods
        
       
       function this = ListDir(varargin)
           
            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
            
            % Add additional varargin arguments
            varargin{length(varargin) + 1} = 'lShowMove';
            varargin{length(varargin) + 1} = false;
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
           
           
           % Pre-process varargin, removing any properties
           % defined in the super class
           
           %{
           cePropsSuper = {'cDir', 'cFilter'}
           for k = 1 : 2: length(varargin)
               
                if any(strcmp(varargin{k}, cePropsSuper))
                    % The prop is a super class prop and needs to 
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
           %}
            
            % Initialize the object for each superclass within the subclass constructor
            % http://www.mathworks.com/help/matlab/matlab_oop/creating-subclasses--syntax-and-techniques.html

            % The trick to passing varargin through is to not pass varargin
            % directly, because this is equivalent to only passing in one argument.
            % The trick is to use varargin{:} which somehow works.
            
            % this@mic.ui.common.List(varargin{:});
            
            % Set the refresh function
            this.setRefreshFcn(@this.refreshList);
            

            this.refresh(); % Make sure this.ceOptions (parent prop) is populated with contents of dir

       end
       
       function build( ...
                this, ...
                hParent, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                dHeight ...
            )
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cTitle,...
                ...% 'Clipping', 'on',...
                ...% 'BorderWidth', 1, ...
                ...% 'BackgroundColor', this.dColorOfPanelBackground, ...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                dWidth ...
                dHeight], hParent) ...
            );
            
            dWidthButton = 100;
            dHeightButton = 24;
                
            dLeft = 10;
            dTop = 20;
                
            if this.lShowChooseDir
                                
                this.uiButtonChooseDir = mic.ui.common.Button(...
                    'fhDirectCallback', @this.onUiButtonChooseDir, ...
                    'cText', 'Choose Dir' ...
                );
            
                this.uiButtonChooseDir.build(...
                    this.hPanel, ...
                    dLeft, ...
                    dTop, ...
                    dWidthButton, ...
                    dHeightButton ...
                );
            
                dLeft = dLeft + 120;
            
            end
            
            this.uiTextDir = mic.ui.common.Text(...
                'cVal', '...' ...
            );

            % addlistener(this.uiButtonChooseDir, 'eChange', @this.onUiButtonChooseDir);

            this.uiTextDir.build(...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidth - dLeft - 10, ...
                dHeightButton ...
            );

            if this.lShowChooseDir
                dTop = dTop + dHeightButton + 10;
            else
                dTop = dTop + 20;
            end
        
            dLeft = 10;
            
            dHeightList = dHeight - dTop - 10;
            
            if this.lShowRefresh || ...
               this.lShowDelete || ...
               this.lShowMove
                dHeightList = dHeightList - 30; % for buttons
            end
            
             build@mic.ui.common.List( ...
                this, ...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                dWidth - 30, ...
                dHeightList ...
            );
           
            this.updateUiTextDir();
            this.refresh();

       end
       
       % Return the full path of the directory the list is currently using
       % @return {char 1xm} c - dir name
       function c = getDir(this)
           c = this.cDir;
       end
       
       
       % @return {struct} state to save
        function st = save(this)
            st = struct();
            st.cDir = this.getDir();
        end
        
        % @param {struct} state to load
        function load(this, st)
            this.cDir = mic.Utils.path2canonical(st.cDir);
            this.refresh(); 
            this.updateUiTextDir();    
        end
       
       
    end
    
    
    methods (Access = protected)
        
        function updateUiTextDir(this)
            
            
            if isempty(this.uiTextDir)
                return
            end
            
            cTooltip = sprintf(...
                'Path of dir: %s', ...
                this.cDir ...
            );
            this.uiTextDir.setTooltip(cTooltip);
            
            dWidthOfCharacter = 7;
            dNumOfCharacters = round(this.uiTextDir.getWidth() / dWidthOfCharacter);
            cVal = mic.Utils.truncate(this.cDir, dNumOfCharacters, true);
            this.uiTextDir.set(cVal);
            
        end
        
        
        function onUiButtonChooseDir(this, src, evt)
           
            cName = uigetdir(...
                fullfile(this.cDir, '..'), ...
                'Please choose a directory' ...
            );
        
            if isequal(cName,0)
               return; % User clicked "cancel"
            end
            
            this.cDir = mic.Utils.path2canonical(cName);
            this.refresh(); 
            this.updateUiTextDir();  
            this.fhOnChangeDir(this, evt);
        end
        
        
        function ceReturn = refreshList(this)
            
            if this.lOrderByReverse
                cOrder = 'ascend';
            else
                cOrder = 'descend';
            end
            
            ceReturn = mic.Utils.dir2cell(...
                this.cDir, ...
                this.cOrderByPredicate, ...
                cOrder, ...
                this.cFilter ...
            );
        end
        
        
        % Override the onDelete method of mic.ui.common.List
        
        function onDelete(this, src, evt)
            ceSelected = this.get();
            
            for k = 1:length(ceSelected)
                cFile = fullfile(this.cDir, ceSelected{k});
                if exist(cFile, 'file') ~= 0
                    % File exists, delete it
                    delete(cFile);
                else
                    this.msg(sprintf('Cannot find file: %s; not deleting.', cFile));
                end
                
            end
            this.refresh();
            
        end

        
    end
    
end