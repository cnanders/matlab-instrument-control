classdef Utils
%UTILS is a static class that contains a set of method useful for
%   dealing with graphical user interface.

    
%% Constant Properties
    properties (Constant)
        bDispLoadSave       = 0;
        dEDITHEIGHT         = 30;
        dLABELHEIGHT        = 15;
        dTEXTHEIGHT         = 15;
        dEditPad            = 10;
        dPanelTopPad        = 20;
        dPanelBotPad        = 10;
        dColorPre           = [0.8 0.8 0.8];
        dColorActive        = [0.9 0.9 0.9];
        dColorPost          = [0.07 0.38 0.07];
                
        
        dColorEditBgDefault    = [0.94 0.94 0.94];
        dColorTextBgDefault    = [0.94 0.94 0.94];
        
        dColorEditBgVerified    = [0.07 0.38 0.07];
        dColorTextBgVerified    = [0.07 0.38 0.07];
        
        dColorEditBgBad         = [0.88 0.57 0.57];
        dColorTextBgBad         = [0.88 0.57 0.57];
         
        cUpDir = sprintf('..%s', filesep)
    end

    %% Static Methods
    methods (Static)
        
        
        function ceReturn = dir2cell(cPath, cSortBy, cSortMode, cFilter)
            
            % cPath         char    dir path without trailing slash
            % cSortBy       char    date, name
            % cSortMode     char    descend, ascend
            % cFilter       char    '*.mat', '*', etc
                        
            if exist('cSortBy', 'var') ~= 1
                cSortBy = 'date';
            end
            
            if exist('cSortMode', 'var') ~= 1
                cSortBy = 'descend';
            end
            
            if exist('cFilter', 'var') ~= 1
                cFilter = '*';
            end
            
                                        
            % Get a structure (size n x 1) for each .mat file.  Each structure
            % contains: name, date, bytes, isdir, datenum
            
            stFiles = dir(sprintf('%s/%s', cPath, cFilter));
            
                    
            % [stFiles.datenum] generates a 1 x m double of Unix
            % timestamps
            %
            % {stFiles.name} generates a 1 x m cell of char of each
            % filename
            
            % When you want to sort by name, you have to do sort on the
            % cell of strings.  Unfortunately,  when you use sort on a cell
            % array of strings, the 'mode' parameter (ascending,
            % descending) does not work.  It will default to ascending and
            % you have to flip afterward if you want descending
            %
            % If you want to sort by date, we can use the datenum property
            % of the structure and can directly use the mode property of
            % the sort function
                                   
            switch (cSortBy)
                
                case 'date'    
            
                    [ceDate, dIndex] = sort([stFiles.datenum], cSortMode);
                    
                case 'name'
                    
                    [ceDate, dIndex] = sort({stFiles.name});

                    switch cSortMode
                        case 'ascend'
                        
                        case 'descend'
                            dIndex = fliplr(dIndex);     
                    end
            end
              
            
            stSortedFiles = stFiles(dIndex);
            ceReturn = {stSortedFiles.name};
                    
            if(isempty(ceReturn))
                ceReturn = cell(1, 0);
            end
            
        end


        function cTruncated = truncate(cText, dLength, lFront)
        %ABBREVIATE truncate a string to the number of specified characters
        %   @param {char 1xm} cText - the text string
        %   @param {double 1x1} dLength - desired length
        %   @param {logical 1x1} lFront - true if you want beginning cut,
        %       false if you want end cut
        %   @return {char 1xm} - truncated text string
        
            if nargin < 2
                dLength = 30;
            end
            
            if nargin < 3
                lFront = false;
            end
            
            if length(cText) > dLength
                if lFront
                    cTruncated = sprintf('...%s', cText(end - dLength : end));
                else
                    cTruncated = sprintf('%s...', cText(1 : dLength));
                end
            else
                cTruncated = cText;
            end
            
        end
        
        % Convert a relative directory path into a canonical path
        % i.e., C:\A\B\..\C becomes C:\A\C.  Uses java io interface
        
        function c = path2canonical(cPath)
           jFile = java.io.File(cPath);
           c = char(jFile.getCanonicalPath);
        end
        
        
        function c = pathImg()
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
            c = fullfile(cDirThis, '..', 'img');
            
        end
        
        function c = pathConfig()
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
            c = fullfile(cDirThis, '..', 'config');
        end
        
        function c = pathSave()
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
            c = fullfile(cDirThis, '..', 'save');
        end

        function checkDir(cPath)
        %CHECKDIR Check that the dir at cPath exists. Make if needed
            
            if (exist(cPath, 'dir') ~= 7)
                cMsg = sprintf('checkDir() creating dir %s', cPath);
                fprintf('%s\n', cMsg);
                mkdir(cPath);
            end
            
        end
        
        function out = lt2lb(dLTWH, hParent)
        %LT2LB Allows to set the position of a uielement from the bottom
        %
        %     Matlab uses the bottom left corner rather the top left for
        %     positioning which makes laying out a GUI a total pain. This
        %     method will let me specify the position of UI elements as
        %     [left top width height], which is the most intuitive way to
        %     do it.  It returns [left bottom width height]
        %
        % out = mic.Utils.lt2lb(dLTWH, hParent)
        %   where  :
        %     dLTWH (double [1x4]) [left top width height] of UI element
        %     hParent (handle) UI parent (usually a panel or figure)
        %
        % See also PANELHEIGHT, UIH, UIW, UD, UICONTROLY
        
            try %FIXME // 2013-11-08 AW : added a try/catch because the element won't draw on a gcf
                dParentPosition = get(hParent,'Position');
                dParentHeight = dParentPosition(4);
                dBottom = dParentHeight - dLTWH(2) - dLTWH(4);

                out = dLTWH;
                out(2) = dBottom;
            catch mE
                disp('Utils::lt2lb unable to draw the element to the specified position')
                out = dLTWH
            end
        end


        % MATLAB functional programming utilities:


        function out = tern(lCondition, mixedTrueValue, mixedFalseValue)
        % Implements a ternary value operator.  Returns either
        % mixedTrueValue or mixedFalseValue depending on lCondition
            if lCondition
                out = mixedTrueValue;
            else
                out = mixedFalseValue;
            end
        end

        function ternEval(lCondition, fhTrueLambda, fhFalseLambda)
        % Implements a ternary function evaluator.  Evaulates either fhTrueLambda or fhFalseLambda
        % depending on lCondition.  Lambdas must be anonymous functions with no inputs
            if lCondition
                fhTrueLambda();
            else
                fhFalseLambda();
            end
        end

        function out = iif(varargin) 
        % Inline If.  Pass {condition, value, condition, value...}
        % returns the first value with the true condition.
            out = varargin{2 * find([varargin{1:2:end}], 1, 'first')}();
        end


        function out = map(mixedList, fhLambda)
        % Functional programming map.  FhLambda can have between 1 and 3
        % arguments, where arguments are (element, index, array)
            switch nargin(fhLambda)
                case 1
                    fhIteratee = (elm, idx, ar) fhLambda(elm);
                case 2
                    fhIteratee = (elm, idx, ar) fhLambda(elm, idx);
                case 3
                    fhIteratee = fhLambda;
            end

            if iscell(mixedList)
                out = cell(size(mixedList));
                for k = 1:numel(mixedList)
                    out{k} = fhIteratee(mixedList{k}, k, mixedList);
                end
            else
                out = zeros(size(mixedList));
                for k = 1:numel(mixedList)
                    out(k) = fhIteratee(mixedList(k), k, mixedList);
                end
            end

        end

        function out = filter(mixedList, fhLambda)
        % Functional programming filter.  FhLambda can have between 1 and 3
        % arguments, where arguments are (element, index, array)
            switch nargin(fhLambda)
                case 1
                    fhIteratee = (elm, idx, ar) fhLambda(elm);
                case 2
                    fhIteratee = (elm, idx, ar) fhLambda(elm, idx);
                case 3
                    fhIteratee = fhLambda;
            end

            if iscell(mixedList)
                out = {};
                for k = 1:numel(mixedList)
                    if fhIteratee(mixedList{k}, k, mixedList)
                        out{end + 1} = mixedList{k};
                    end
                end
            else
                out = [];
                for k = 1:numel(mixedList)
                    if fhIteratee(mixedList(k), k, mixedList)
                        out(end + 1) = mixedList(k);
                    end
                end
            end
        end


    end % Static
end

