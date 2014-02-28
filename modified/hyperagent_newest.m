function [M,W_selected,R,S,K,qual_auth_names,idx] = hyperagent_newest(R,K,alpha)

%========================= DATE PREPERATION ==============================
%m = 126406; % # Vertices 
%n = 85233; % # Edges 
N = 22; % # Skills
t_2 = toc;
% Hyper-incidence matrix H (m # Vertices X n # Edges)
H_Idx = load('collab_sparse_tuples_out.txt');
H = sparse(H_Idx(:,2)+1, H_Idx(:,1)+1, ones(size(H_Idx,1),1));
n_original = size(unique(H_Idx(:,1)),1); % # Hyper Edges 
m_original = size(unique(H_Idx(:,2)),1); % # Vertices 

% Weight (Kapoor et al. 2013)
W_mat = load('collab_weight_out.txt'); 

% Node Skill Matrix Q (m x |U|) % where U = {a1,a2,.....,aN} skills.
Q = load('collab_skill_mat_out.txt');
Q = Q(1:m_original,1:N);

% Extract the qualified edges and vertices.
qual_edges = find(sum(H'*Q,2)>0); % Get rid of edges with total skill = 0
H = H(:,qual_edges);
qual_vertices = find(sum(H,2)>0); % Get rid of vertices not part of any edge.
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

fprintf('Time taken for Data Preperation: %f\n',toc-t_2);                                            
% ========================= LABEL PROPAGATION =============================
label = sum(Q(:,R>0),2);

% Randomly select 20% of data as test set and set the parameters for HyperPrior
[Train, Test] = crossvalind('HoldOut', label, 0.2);
%alpha = 0.1;

% Semi-supervised learning by HyperPrior
%[F] = HyperModified(H, label, Test, alpha, W);
[F] = HyperModifiedVectorized(H, label, Test, alpha, W);

[~,idx] = sort(F,'descend');
%idx
%disp(['The AUC of HyperPrior is ' num2str(AUC) ' for this experiment.']);

% Find the Top-K vertices
% K = 1000;

for i = 1:K
    disp(qual_auth_names{idx(i)});
end

% Top Hyperedge Sets : S (|S| x m)
% find(sum(H(idx(1:K)',:),1)>0)
% S = H(idx(1:K)',sum(H(idx(1:K)',:),1)>0)';
S = H(:,sum(H(idx(1:K)',:),1)>0)';
% Q = Q(idx(1:K)',:);

% Hyperedge Skill Matrix M(s,a)
M = S * Q;
W_selected = W(sum(H(idx(1:K)',:),1)>0);
end
