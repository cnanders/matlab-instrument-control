classdef List < mic.Base
    
    % TO DO
    % Update with proper interface
    
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
        hDelete
        hMoveUp
        hMoveDown
        hRefresh
        
        % {logical 1x1} show delete button
        lShowDelete = true 
        
        % {logical 1x1} show move buttons
        lShowMove = true   
        
        % {logical 1x1} show label
        lShowLabel = true   
        
        % {logical 1x1} show show onRefresh button.  If you show this, you
        % need to supply the function handle to use that returns a cell of
        % options
        lShowRefresh = true
        
        % {char 1xm} the label
        cLabel = 'Fix Me'        
        
        % {function_handle 1x1} function to call when the refresh button is
        % pushed
        fhRefresh       
        
        % {function_handle 1x1} function to call when the list selection
        % changes
        fhOnChange = @(src, evt)[];
        
        % {function_handle 1x1} callback when user presses up, down, or X
        fhDirectCallback = @()[];
        
        dWidthDelete    = 60;
        dWidthUp        = 60;
        dWidthDn        = 60;
        dWidthRefresh   = 60;
        dPad            = 5;
        dHeightButton = 24
        cLabelDelete = 'Delete'
        cLabelMoveUp = 'Up'
        cLabelMoveDown = 'Down'
        cLabelRefresh = 'Refresh'

        % {cell 1xn} list of options
        ceOptions              

        % {uint8 1xm} list of selected indexes
        u8Selected 
                   
    end
    
    
    events
        
        % {event} whenever the selected index(es) changes
        eChange
        eDelete
    end
    
    
    methods
        
       % constructor
       
       % LEGACY
       %{
        ceOptions, ...
        cLabel, ...
        lShowDelete, ...
        lShowMove, ...
        lShowLabel, ...
        lShowRefresh ...
       %}
       
       function this= List(varargin)
           
            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
       end
       
       
       function build( ...
                this, ...
                hParent, ...
                dLeft, ...
                dTop, ...
                dWidth, ...
                dHeight ...
            )
                       
           if this.lShowLabel
               
                this.hLabel = uicontrol( ...
                    'Parent', hParent, ...
                    'Position', mic.Utils.lt2lb([dLeft dTop dWidth 20], hParent),...
                    'Style', 'text', ...
                    'String', this.cLabel, ...
                    'FontWeight', 'Normal',...
                    'HorizontalAlignment', 'left'...
                );
           
                dTop = dTop + 15;
           end
           
           this.hUI = uicontrol( ...
                'Parent', hParent, ...
                'BackgroundColor', 'white', ...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style', 'listbox', ...
                'String', this.ceOptions, ...
                'Min', 0, ...
                'Max', 2, ... % allows for multiple selection
                'Callback', @this.onList ...
           );
            
           dRight = dLeft + dWidth;
           
           if this.lShowDelete
              
               this.hDelete = uicontrol(...
                'Parent', hParent,...
                'Position', mic.Utils.lt2lb([ ...
                    dRight - this.dWidthDelete ...
                    dTop + dHeight + 5 ...
                    this.dWidthDelete ...
                    this.dHeightButton], hParent),...
                'HorizontalAlignment', 'Center',...
                'Style', 'pushbutton', ...
                'String', this.cLabelDelete,...
                'Callback', @this.onDelete ...
                );
            
                dRight = dRight - this.dWidthDelete - this.dPad;
               
           end
           
           
           if this.lShowMove
               
                this.hMoveUp = uicontrol(...
                    'Parent', hParent,...
                    'Position', mic.Utils.lt2lb([ ...
                        dRight - this.dWidthUp ...
                        dTop + dHeight + 5 ...
                        this.dWidthUp ...
                        this.dHeightButton], hParent),...
                    'HorizontalAlignment', 'Center',...
                    'Style', 'pushbutton', ...
                    'String', this.cLabelMoveUp,...
                    'Callback', @this.onMoveUp ...
                );
            
               dRight = dRight - this.dWidthUp - this.dPad;
            
               this.hMoveDown = uicontrol(...
                    'Parent', hParent,...
                    'Position', mic.Utils.lt2lb([ ...
                        dRight - this.dWidthDn ...
                        dTop + dHeight + 5 ...
                        this.dWidthUp ...
                        this.dHeightButton], hParent),...
                    'HorizontalAlignment', 'Center',...
                    'Style', 'pushbutton', ...
                    'String', this.cLabelMoveDown,...
                    'Callback', @this.onMoveDown ...
               );
            
               dRight = dRight - this.dWidthDn - this.dPad;

           end
           
           
           if this.lShowRefresh
               
              this.hRefresh = uicontrol( ...
                'Parent', hParent, ...
                'Position', mic.Utils.lt2lb([ ...
                    dRight - this.dWidthRefresh ...
                    dTop + dHeight + 5 ...
                    this.dWidthRefresh ...
                    this.dHeightButton], hParent),...
                'HorizontalAlignment', 'Center', ...
                'Style', 'pushbutton', ...
                'String', this.cLabelRefresh, ...
                'Callback', @this.onRefresh ...
                ); 
               
           end

       end
       
       
       
       
       function setRefreshFcn(this, fh)
           this.fhRefresh = fh;
       end
       
        % @return % {cell 1xm} list of selected values
       function ce = get(this)
            ce = this.ceOptions(this.u8Selected);
       end


        % @return {uint8 1xm} list of selected indexes
        function u8 = getSelectedIndexes(this)
            u8 = this.u8Selected;
        end

        
        % @return {cell 1xn} list of options
        function ce = getOptions(this)
            ce = this.ceOptions;
        end
       
       function setOptions(this, ceVal)
          
           % prop
           if iscell(ceVal) % empty cell [1x0] is allowed
                this.ceOptions = ceVal;
                
                if isempty(this.ceOptions)
                    % no options in list ...
                    
                    this.u8Selected = uint8([]); % uint8 [0x0] empty array is allowed
                else
                    % options...
                    
                    if ~isempty(this.u8Selected)
                        
                        % Check max(u8Selected) to make sure there are all
                        % selected indicies are valid and modify u8Selected
                        % if needed to make it comply (this happens when
                        % you update to a list cell with less items than the
                        % previous one and a selected item on the previous
                        % cell would extend past thi new option cell
                    
                        if max(this.u8Selected) > length(this.ceOptions)
                            this.u8Selected = uint8(length(this.ceOptions));
                        else
                            % Make sure to re-set u8Selected so the setter
                            % is called which updates this.ceSelected.  If
                            % you don't call the setter (or manualy update
                            % ceSelected, it won't be updated)
                            
                            this.u8Selected = this.u8Selected; 
                            
                        end
                    else
                        
                        % default to first item 
                        this.u8Selected = uint8(1); 
                    end
                end
                
           end
           
           % ui
           if ~isempty(this.hUI) && ishandle(this.hUI)
                set(this.hUI, 'Value', this.u8Selected);
                set(this.hUI, 'String', this.ceOptions);               
           end
           
           
           
       end
       
        % @param {uint8 1xm} list of indexes to programatically select
       function setSelectedIndexes(this, u8Val)
           
           % prop
           if isinteger(u8Val) % uint8 [0x0] empty array is allowed
               
               if isempty(u8Val)
                   this.u8Selected = [];
               elseif(max(u8Val) <= length(this.ceOptions))
                   this.u8Selected = u8Val; 
               end
               
               
           else
                cMsg = sprintf('The indexes you provided are not {uint8} type.  Please cast as uint8 and try again.');
                cTitle = 'uint8 index type required';
                msgbox(cMsg, cTitle, 'warn') 
               
           end
           
           % ui
           if ~isempty(this.hUI) && ishandle(this.hUI)
               set(this.hUI, 'Value', this.u8Selected);
           end
           
           this.fhOnChange(this)
           notify(this,'eChange');
               
       end
       
       
       function prepend(this, cVal)
           % add item to beginning of ceOptions
           if ischar(cVal)
               this.ceOptions = {cVal this.ceOptions{:}};
                this.setOptions(this.ceOptions);
           end
           
           this.fhOnChange(this)
           this.fhDirectCallback();
           
           
       end
       
       function append(this, cVal)
           % adds item to end of ceOptions
           if ischar(cVal)
               this.ceOptions{end+1} = cVal;
               this.u8Selected = uint8(length(this.ceOptions));
                this.setOptions(this.ceOptions);
           end
           
           this.fhOnChange(this)
           this.fhDirectCallback();
           
       end
       
       
       function insertBefore(this, cVal)
           % should only work when one option is selected. Inserts before
           % selected item
       end
       
       function insertAfter(this, cVal)
           % should only work when one option is selected. Inserts after
           % selected item
       end
       

        % @return {struct} state to save
        function st = save(this)
            st = struct();
            st.u8Selected = this.u8Selected;
        end
        
        % @param {struct} state to load
        function load(this, st)
            this.setSelectedIndexes(st.u8Selected);
        end

        function refresh(this)
            this.setOptions(this.fhRefresh());
        end
       
            
    end

    methods (Access = protected)

       function onList(this, src, evt)
            this.u8Selected = uint8(get(src, 'Value'));
            
            if ~isempty(this.fhOnChange)
               this.fhOnChange(this, evt)
            end
           
            notify(this,'eChange');
       end
       
       
       function onRefresh(this, src, evt)
           this.msg('onRefresh');
           this.refresh()
       end

        function onMoveDown(this, src, evt)
           % moves selected options down the list
           
           if max(this.u8Selected) ~= length(this.ceOptions)
               % loop through each selected item and swap it with the one
               % above it

               % 2017.03.24 Need to go in reverse order when moving down
               % multiple

               for n = fliplr(this.u8Selected)
                   this.ceOptions([n, n + 1]) = this.ceOptions([n + 1, n]);
               end
               
               this.u8Selected = this.u8Selected + 1;

               this.setOptions(this.ceOptions);
                
               % perform callback
               this.fhDirectCallback();
           end
       end

       function onMoveUp(this, src, evt)
           % moves selected options up the list
           
           if min(this.u8Selected) ~= 1
               % loop through each selected item and swap it with the one
               % above it
               for n = this.u8Selected
                   this.ceOptions([n, n - 1]) = this.ceOptions([n - 1, n]);
               end
               
               this.u8Selected = this.u8Selected - 1;
               this.setOptions(this.ceOptions);
               
               % perform callback
               this.fhDirectCallback();
           end

           
       end

        function onDelete(this, src, evt)
           
           % removes selected options ceOptions
           
           % 2014.05.08 CNA
           % Dispatching an eDelete event and passing data that is a cell
           % of the selected options that are being removed.  In order to
           % pass custom data through Matlab events and listeners, you have
           % to build a custom class that extends event.EventData and add
           % whatever properties you want.  See classes/EventWithData for
           % more information
           
           
           stData = struct();
           stData.ceOptions = this.ceOptions(this.u8Selected);
           notify(this, 'eDelete', mic.EventWithData(stData));
           
           this.ceOptions(this.u8Selected) = [];

           this.setOptions(this.ceOptions);
           
           % perform callback
           this.fhDirectCallback();
       end
       
       


    end
end