classdef ScanStatus < mic.Base
    
    properties (Constant)
        dHeight = 80
    end
    
    properties (Access = private)
        
       hPanel
       
       uiTextLabelStatus
       uiTextLabelTimeElapsed
       uiTextLabelTimeRemaining
       uiTextLabelTimeComplete
       
       uiTextStatus
       uiTextTimeElapsed
       uiTextTimeRemaining
       uiTextTimeComplete
       
       dWidthLabel = 60
       dWidthValue = 50;
       dHeightText = 16;
       dHeightPadText = 0
       
       dHeightPadPanel = 20
       dWidthPadPanel = 10
       cTitlePanel = ''
       
       
       
    end
    
    methods
        
        function this = ScanStatus()
            this.init()
        end  
        
        
        function build(this, hParent, dLeft, dTop)
            
            dWidth = this.dWidthPadPanel + ...
                this.dWidthLabel + ...
                this.dWidthValue + ...
                this.dWidthPadPanel;
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cTitlePanel,...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth this.dHeight], hParent) ...
            );
        
            dLeft = 10;
            dTop = this.dHeightPadPanel;
            
            %{
            this.uiTextLabelStatus.build(this.hPanel, dLeft, dTop, this.dWidthLabel, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            %}
            this.uiTextLabelTimeElapsed.build(this.hPanel, dLeft, dTop, this.dWidthLabel, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            this.uiTextLabelTimeRemaining.build(this.hPanel, dLeft, dTop, this.dWidthLabel, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            this.uiTextLabelTimeComplete.build(this.hPanel, dLeft, dTop, this.dWidthLabel, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            dLeft = dLeft + this.dWidthLabel;
            dTop = this.dHeightPadPanel;
            
            %{
            this.uiTextStatus.build(this.hPanel, dLeft, dTop, this.dWidthValue, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            %}
            this.uiTextTimeElapsed.build(this.hPanel, dLeft, dTop, this.dWidthValue, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            this.uiTextTimeRemaining.build(this.hPanel, dLeft, dTop, this.dWidthValue, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            this.uiTextTimeComplete.build(this.hPanel, dLeft, dTop, this.dWidthValue, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
        end
        
        % @param {Status 1x1} - see mic.StateScan
        function setStatus(this, st)
            cTitle = sprintf('%s %s', ...
                this.cTitlePanel, ...
                st.cStatus ...
            );
            set(this.hPanel, 'Title', cTitle);
            % this.uiTextStatus.set(st.cStatus);
            this.uiTextTimeElapsed.set(st.cTimeElapsed);
            this.uiTextTimeRemaining.set(st.cTimeRemaining);
            this.uiTextTimeComplete.set(st.cTimeComplete);
        end
        
    end 
    
    methods (Access = private)
        
        function this = init(this)
            
            this.uiTextLabelStatus = mic.ui.common.Text(...
                'cVal', 'Status:' ...
            );
            this.uiTextLabelTimeElapsed = mic.ui.common.Text(...
                'cVal', 'Elapsed:' ...
            );
            this.uiTextLabelTimeRemaining = mic.ui.common.Text(...
                'cVal', 'Remaining:' ...
            );
            this.uiTextLabelTimeComplete = mic.ui.common.Text(...
                'cVal', 'Complete:' ...
            );
        
            this.uiTextStatus = mic.ui.common.Text(...
                'cVal', '...' ...
            );
            this.uiTextTimeElapsed = mic.ui.common.Text(...
                'cVal', '...' ...
            );
            this.uiTextTimeRemaining = mic.ui.common.Text(...
                'cVal', '...' ...
            );
            this.uiTextTimeComplete = mic.ui.common.Text(...
                'cVal', '...' ...
            );
        
        end
    end
    
end

