function Tdummy = dummytable(T)
% Tdummy = dummytable(T) - convert categorical variables in table to dummy
% variables
%
% This function takes the categorical variables in a table and converts
% them to separate dummy variables with intelligent names.  This way they
% can be used in the Classification Learner App and the variable names make
% sense for feature selection, etc.
%
% Usage:
%
%     Tdummy = dummytable(T)
%
% Inputs:
%
%     T:        Table with categoricals or categorical variable
%
% Outputs: 
%
%     Tdummy:   T with categorical variables turned into dummy variables with
%               intelligent names
%
% Example:
%
%        % Simple Table
%        T = table(rand(10,1),categorical(cellstr('rbbgbgbbgr'.')),...
%           'VariableNames',{'Percent','Color'});
%        disp(T)
% 
%        % Turn it into a dummy table 
%        Tdummy = dummytable(T);
%        disp(Tdummy)
%
% See Also: dummyvar, table, categorical, classificationLearner

% Copyright 2015 The MathWorks, Inc.
% Sean de Wolski Apr 13, 2014

      % Error checking
      narginchk(1,1)    
      validateattributes(T,{'categorical', 'table'},{},mfilename,'T',1);

      % If it's a categorical, do out best to convert it to a table with an
      % intelligent variable name
      if iscategorical(T)
          % Try to use existing variable name
          cname = inputname(1);
          if isempty(cname)
              % It's a MATLAB Expression, default to Var1
              cname = 'Var1';
          end
          T = table(T,'VariableNames',{cname});
      end 

      % Identify categoricals and their names
      cats = varfun(@iscategorical,T,'OutputFormat','uniform');

      % Short circuit if there are no categoricals
      if ~any(cats)
          Tdummy = T;
          return
      end            

      % Store everything in a cell.  w will be the total width of the table
      % with each variable dummyvar'd
      w = nnz(~cats)+sum(varfun(@(x)numel(categories(x)),T(:,cats),'OutputFormat','uniform'));

      % Preallocate storage
      datastorage = cell(1,w);
      namestorage = cell(1,w);

      % Engine
      idx = 0; % Start nowhere in cell
      for ii = 1:width(T)
          idx = idx+1;
          % Loop over table deciding what to do with each variable
          if cats(ii)
              % It's a categorical,
              % Extract it and build keep its categories and dummyvar
              Tii = T{:,ii};
              categoriesii = categories(Tii)';
              ncatii = numel(categoriesii); % How many?

              % Build dummy var as a row cell with columns in each
              dvii = num2cell(dummyvar(Tii), 1); % Dummy var then cell                                    

              % Build names
              namesii = strcat(T.Properties.VariableNames{ii}, '_', categoriesii);

              % Insert
              datastorage(idx:(idx+ncatii-1)) = dvii;
              namestorage(idx:(idx+ncatii-1)) = namesii;

              % Increment
              idx = idx+ncatii-1;                        

          else
              % Extract non categorical into current storage location
              datastorage{idx} = T{:,ii};
              namestorage(idx) = T.Properties.VariableNames(ii);
          end
      end

      % Build Tdummy with comma separated list expansion
      Tdummy = table(datastorage{:},'VariableNames',matlab.lang.makeValidName(namestorage));

end