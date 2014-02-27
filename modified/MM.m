function [S_sub,S,U,x_star] = MM(M,R,S,K,qual_auth_names,idx)
%========================= MULTI-SET MULTI-COVER (MM)  ===================
% N is the number of skillls 
% Requirement vector R (|U| x 1)
% R = zeros(m,1);
% R = [1; 1; 1; 1]; % Too low but all
% R = [10; 10; 10; 10]; % Not possible
% R = [20; 0; 1; 0]; % Not possible
% R = [20; 0; 0; 0]; 

% # Extracted hyper-edges: hm
hm = size(M,1);
f = ones(hm,1);
% M'*f
prep_idx = find(sum(M,1)>=1);
A = -M';
b = -R';
% prep_idx = find(sum(A,2)>=1);
prep_len = size(prep_idx,1);
A_prep = A(prep_idx,:);
b_prep = b(prep_idx,:);
lb = zeros(hm,1); 
ub = ones(hm,1);
% x_star = linprog(f,A,b,[],[],[],[])
x_star = linprog(f,A_prep,b_prep,[],[],lb,ub);
plot(x_star)
% for i=1:size(S,1), find(S(i,:)==1), M(i,:), end

% ============================ MM Rounding ===============================
c = ceil(log(4*K)/log(K));
acc_iter = ceil(c*log(K));
count = 0;
while true
U = zeros(hm,1);
for i = 1:hm
    x = rand(acc_iter,1);
        
   if sum(x < x_star(i)) > 0
       U(i,1) = 1;
   end
 %}
 %{
    if rand(1)<= x_star(i)
        U(i,1) = 1;
    end
 %}
end

if A*U <= b 
    break;    
elseif count > 10000
    break;
end
count = count + 1;
end

fprintf('Number of rounding iterations: %d \n',count);
S_idx = find(U>0)';
S_sub = S(S_idx,:);

% for i=1:size(S,1), find(S(i,:)==1), M(i,:), end
for i = 1 : size(S_idx,2)
    fprintf('Group No.%d : \n',i)
    for j = 1:size(M,2)
        if R(j)>0
            fprintf('Skill %d : %d, ',j,M(S_idx(i),j));
        end
    end
    fprintf('\n');
    for j = find(S_sub(i,:) == 1)
        fprintf('%s - ',qual_auth_names{idx(j)});
    end
    fprintf('\n');
    disp('=========');
end
end