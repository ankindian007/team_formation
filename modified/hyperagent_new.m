%========================= DATE PREPERATION =============================
%m = 126406; % # Vertices 
%n = 85233; % # Edges 
N = 22; % # Skills

% Hyper-incidence matrix H (n # Edges X m # Vertices)
H_Idx = load('collab_sparse_tuples_out.txt');
H = sparse(H_Idx(:,2)+1, H_Idx(:,1)+1, ones(size(H_Idx,1),1));
n_original = size(unique(H_Idx(:,1)),1); % # Hyper Edges 
m_original = size(unique(H_Idx(:,2)),1); % # Vertices 

% Weight (Kapoor et al. 2013)
W_mat = load('collab_weight_out.txt'); 

% Node Skill Matrix Q (m x |U|) % where U = {a1,a2,.....,aN} skills.
Q = load('collab_skill_mat_out.txt');
Q = Q(1:m_original,1:N);

qual_edges = find(sum(H'*Q,2)>0);
H = H(:,qual_edges);
qual_vertices = find(sum(H,2)>0);
H = H(qual_vertices,:);
W = W_mat(qual_edges,2);
[m,n] = size(H);
Q = Q(qual_vertices,:);

fid = fopen('author_list_out.txt');
auth_count = 1;
auth_names = cell(m_original,1);
new_count = 1;
while 1
    author = fgetl(fid);
    %if size(find(qual_vertices == auth_count),1) >0 
        auth_names{auth_count,1} = author;
        new_count = new_count + 1;
    %end
    
    if ~ischar(author), break, end
    
    auth_count = auth_count + 1;
end
fclose(fid);
qual_auth_names = cell(m,1);
for i = 1 : m
    qual_auth_names{i} = auth_names{qual_vertices(i)};
end

%========================= LABEL PROPAGATION =============================

label = sum(Q(:,find(R>0)),2);

% Randomly select 20% of data as test set and set the parameters for HyperPrior
[Train, Test] = crossvalind('HoldOut', label, 0.2);
alpha = 0.1;

% Semi-supervised learning by HyperPrior
%[F] = HyperModified(H, label, Test, alpha, W);
[F] = HyperModifiedVectorized(H, label, Test, alpha, W);

[~,idx] = sort(F,'descend');
%idx
%disp(['The AUC of HyperPrior is ' num2str(AUC) ' for this experiment.']);

% Find the Top-K vertices
K = 1000;

for i = 1:K
    disp(qual_auth_names{idx(i)});
end

% Top Hyperedge Sets : S (|S| x m)
% find(sum(H(idx(1:K)',:),1)>0)
S = H(:,find(sum(H(idx(1:K)',:),1)>0))';

% Hyperedge Skill Matrix M(s,a)
M = S * Q;

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
acc_iter = 100000;
count = 0;
while true
U = zeros(hm,1);
for i = 1:hm
%    y = zeros(acc_iter,1);
%    x = rand(acc_iter,1);
%    y(x < x_star(i)) = 1;
%    sum(y)

%   if sum(y)/acc_iter <= x_star(i)
%       U(i,1) = 1;
%   end
% x_star(i)
if rand(1)<= x_star(i)
    U(i,1) = 1;
end
end

count = count + 1;
if A*U >= R' 
    break;    
elseif count > 10000
    break;
end
end
S_sub = S(find(U>0),:);
count
U'
% for i=1:size(S,1), find(S(i,:)==1), M(i,:), end
for i=1:size(S_sub,1), find(S_sub(i,:)==1), end
%{
n = 4;
p = [0.4 0.1 0.1 0.9];
k = size(p,2);
u = rand(1,n);
x = zeros(1,n);
for i=1:k
    i*(sum(p(1:i-1))<=u & u<sum(p(1:i)))
    x=x+i*(sum(p(1:i-1))<=u & u<sum(p(1:i)));
end
x
%}