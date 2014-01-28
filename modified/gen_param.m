
function [R] = gen_param()

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

% Extract the qualified edges and vertices.
qual_edges = find(sum(H'*Q,2)>0);
H = H(:,qual_edges);
qual_vertices = find(sum(H,2)>0);
H = H(qual_vertices,:);
W = W_mat(qual_edges,2);
Q = Q(qual_vertices,:);

% Complete hyperedge x skill matrix
S = H' * Q;
max_skill = max(S,[],1);

R = zeros (110,22); % [(3:13) skills x (10) random gen] x [(22) skills]
count =1;
for team_sz = 3:13
    for i = 1:10
        a = randperm(13,team_sz);
        R(count,a) = arrayfun(@(x) (randi(x)), max_skill(a));
        count = count +1;
    end
end

end