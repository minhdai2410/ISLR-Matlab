function confusiontable = confusiontable(vector1, vector2)
%% Create confusion table
    [table,~,~,labels] = crosstab(vector1, vector2);
    labelsCol = labels(~cellfun('isempty',labels(:,2)),2);
    labelsRow = labels(~cellfun('isempty',labels(:,1)),1);
    confusiontable = array2table(table,...
            'VariableNames',strcat({[inputname(2) '. ']},labelsCol),...
            'RowNames',strcat({[inputname(1) '. ']},labelsRow));
    accuracy = 0;
    for i = 1:length(labelsRow)
        for j = 1:length(labelsCol)
            if isequal(labelsRow(i),labelsCol(j))
                accuracy = accuracy + table(i,j);
            end
        end   
    end
%     fprintf('The accuracy of the model is: %f\n', accuracy/sum(sum(table)));
end