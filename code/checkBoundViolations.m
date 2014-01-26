function checkBoundViolations(A,b,ub,lb)

for i = 1:size(A,1)
    [~, inds, ~] = find(A(i,:));  %finds nonzero indices and values in the ith row of A
    
    %if there is only one nonzero value on the ith row, then there may be a problem
    if numel(inds) == 1 
        %determine the value of x in the ith row
        xi = b(i)/A(i,inds);
        %see if x violates the upper bound
        if xi > ub(i)
            disp(['row ',num2str(i), ' implies x(',num2str(inds),') = ',num2str(xi),': violates upper bound'])
        end
        %see if x violates the lower bound
        if xi < lb(i)
            disp(['row ',num2str(i), ' implies x(',num2str(inds),') = ',num2str(xi),': violates lower bound'])
        end
    end
end