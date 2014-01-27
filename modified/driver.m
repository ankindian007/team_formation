alpha = 0.1;

% Single Skill Test
K = 100;
R = [100 zeros(1,11) 1000 zeros(1,9)];
[M,R,S,K,qual_auth_names] = hyperagent_newest(R,K,alpha);

% Node Skill Matrix Q (m x |U|) % where U = {a1,a2,.....,aN} skills.
Q = load('collab_skill_mat_out.txt');
Q = Q(1:m_original,1:N);



[S,H,U,x_star] = MM(M,R,S,K,qual_auth_names);


% Density (# of Nodes/ # of Edges) Curve V/S # of Skills for a given K

for N_skill = 1:22
    
end

% Team Size Curve V/S # of Skills for a given K


