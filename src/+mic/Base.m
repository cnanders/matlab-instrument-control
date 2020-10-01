classdef Base < handle

    properties (Constant, Access = protected)

        
        u8_MSG_TYPE_INFO = 1
        u8_MSG_TYPE_ERROR = 2
        u8_MSG_TYPE_EVENT_SENT = 3
        u8_MSG_TYPE_EVENT_RECEIVED = 4
        u8_MSG_TYPE_EVENT_LISTENER_ADDED = 5
        u8_MSG_TYPE_JAVA = 6
        u8_MSG_TYPE_CLOCK = 7
        u8_MSG_TYPE_LOAD_SAVE = 8
        u8_MSG_TYPE_CLASS_INIT = 9
        u8_MSG_TYPE_VARARGIN_SET = 10
        u8_MSG_TYPE_VARARGIN_PROPERTY = 11
        u8_MSG_TYPE_FILE_IO = 12
        u8_MSG_TYPE_DELETE = 13
        u8_MSG_TYPE_CREATE_UI_COMMON = 14
        u8_MSG_TYPE_CREATE_UI_DEVICE = 15
        u8_MSG_TYPE_PROP_DELETED = 16
        u8_MSG_TYPE_PROP_DELETE_SKIPPED = 17
        u8_MSG_TYPE_PROP_DELETE_CHECK = 18
        u8_MSG_TYPE_SCAN = 19
        u8_MSG_TYPE_CLASS_DELETE = 20
        
        u8_MSG_STYLE_ALL = [1 : 19]
        u8_MSG_STYLE_ALL_LESS_CLOCK = [1 : 6, 8 : 19]
        u8_MSG_STYLE_CLOCK = [7]
        u8_MSG_STYLE_JAVA = [5]
        u8_MSG_STYLE_EVENTS_AND_JAVA = [3, 4, 5, 6]
        u8_MSG_STYLE_CLOCK_AND_EVENTS = [3, 4, 5, 7]
        u8_MSG_STYLE_VARARGIN_SET = [10] 
        u8_MSG_STYLE_VARARGIN_ALL = [10, 11]
        u8_MSG_STYLE_NONE = []
        u8_MSG_STYLE_CREATE_UI_DEVICE = [15]
        u8_MSG_STYLE_CREATE = [14, 15] 
        u8_MSG_STYLE_CLASS_INIT_DELETE = [9, 20, 16, 17, 18]
        u8_MSG_STYLE_SCAN = [19]
        u8_MSG_STYLE_INFO = [1]
        
    end
    
    properties (Access = protected)
        u8MsgStyle
    end
    
    
    methods 
        
        function this = Base()
           % this.u8MsgStyle = this.u8_MSG_STYLE_ALL;
            % this.u8MsgStyle = this.u8_MSG_STYLE_INFO;
            this.u8MsgStyle = this.u8_MSG_STYLE_SCAN;
            % this.u8MsgStyle = this.u8_MSG_STYLE_CLASS_INIT_DELETE; 
           % this.u8MsgStyle = this.u8_MSG_STYLE_NONE;
        end


    end 
    
    % 2013-11-20 AW added method overloads to remove 'handle' class
    % for the listed methods of the class.
    % This is better for cod pretty-print and autocompletion
    % http://stackoverflow.com/questions/6621850/is-it-possible-to-hide-the-methods-inherited-from-the-handle-class-in-matlab
    methods(Hidden)
        
        
        % Prints a message to the command window if provided message type
        % is included in this.u8MsgStyle list of allowed message types
        % @param {char 1xm} cMsg - the message
        % @param {uint8 1x1} u8Type - see this.u8_MSG_TYPE_*
        function msg(this, cMsg, u8Type)
        
            
            if nargin == 2
                u8Type = this.u8_MSG_TYPE_INFO;
            end
            
            % Always show error types
            u8MsgStyle = [this.u8MsgStyle this.u8_MSG_TYPE_ERROR this.u8_MSG_TYPE_DELETE];

            if any(ismember(u8MsgStyle, u8Type))
                 cTimestamp = datestr(datevec(now), 'yyyymmdd-HHMMSS', 'local');
                 fprintf('%s: %s %s\n', cTimestamp, this.id(), cMsg);
            end
            

            % Obtrusive message box for errors, since they are bad and want
            % user to be aware
            

            if u8Type == this.u8_MSG_TYPE_ERROR
                
                % Obtrusive message box for errors, since they are bad and want
                % user to be aware
            
                %{
                msgbox( ...
                    cMsg, ...
                    'Error', ...
                    'error', ...
                    'modal' ...
                );
                %}
                %error(cMsg);
            end
           
        end

        function cID = id(this)
        %ID Gives the Class of which this object is an instance
        %   cID = Base.id()
            if this.hasProp( 'cName')
                cID =  sprintf('%s-%s', class(this), this.cName);
            % elseif this.hasProp( 'cLabel')
                % cID =  sprintf('%s-%s', class(this), this.cLabel);
            else
                cID = class(this);
            end
        end
        
        function hFigure = getParentFigure(this)
            if this.hasProp('hFigure') && isa(this.hFigure, 'figure')
                hFigure = this.hFigure;
                return
            else
                if this.hasProp('hParent')
                    if (isa(this.hParent, 'figure'))
                        hFigure = this.hParent;
                        return
                    else
                        hFigure = this.getParentFigure(this.hParent);
                        return
                    end
                end
            end
            hFigure = {};
        end
        
        
        %%
        % @param {char 1xm} c - name of property
        % @return {logical 1x1} - true if class has property
        
        function l = hasProp(this, c)
            l = false;
            if length(findprop(this, c)) > 0
                l = true;
            end
        end
        
        
    end
    
end %classdef
        
        
