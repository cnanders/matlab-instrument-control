classdef ImageLogical < mic.interface.ui.common.ImageLogical & mic.ui.common.Base


    properties

        
    end


    properties (Access = private)
        
        hAxes
        hImage
        
        dWidth = 24
        dHeight = 24
        u8ImgTrue
        u8ImgFalse
        cDirThis
        
        uiText
        
        u8TrueColor = [0, 0.8, 0]
        u8FalseColor = [0.75, 0.75, 0.75]
    end


    %%
    methods
        
        function this= ImageLogical(varargin)


            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            
            this.uiText = mic.ui.common.Text('cVal', '', 'cAlign', 'right');

            
            
        end

        function build(this, hParent, dLeft, dTop)
            
            this.uiText.build(hParent, dLeft, dTop, this.dWidth, this.dHeight);
            this.uiText.setBackgroundColor(this.u8FalseColor);

            return;
            
            dPosition = mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent);
            this.hAxes = axes( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Position', dPosition,...
                'Color', [0 0 0], ...
                'Color', [0 0 0], ...
                'HandleVisibility', 'on', ...
                'Visible', 'off', ... % 'LineWidth', 0, ...
                'DataAspectRatio' , [1 1 1] ...
            );
            drawnow;
        
%             this.hImage = image(...
%                 'CData', this.u8ImgFalse, ...
%                 'Parent', this.hAxes ...
%             );

            this.hImage = image(this.hAxes, this.u8ImgFalse);
            
%             set(this.hImage, 'Parent', this.hAxes);
            
            % set(this.hAxes, 'XTick', []); % gets rid of axes and gridlines
            % set(this.hAxes, 'YTick', []); % gets rid of axes and gridlines
            % set(this.hAxes, 'box', 'off');
            set(this.hAxes, 'Visible', 'off');
           
        end
        
        % @param {logical 1x1} the state
        function set(this, l)
            
            % Overriding with text to make more performant
            if l
                this.uiText.setBackgroundColor(this.u8TrueColor);
            else
                this.uiText.setBackgroundColor(this.u8FalseColor);
            end
            
            return;
            
            if ~ishandle(this.hImage)
                return
            end
            
            if l
                set(this.hImage, 'CData', this.u8ImgTrue);
            else
                set(this.hImage, 'CData', this.u8ImgFalse);
            end
        end
        
        


    end
end