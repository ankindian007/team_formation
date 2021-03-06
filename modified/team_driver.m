function [] = team_driver()
alpha = 0.1; % label propagation parameter
K = 100; % Max size of team allowed

% Old Single Skill Test
% R = [100 zeros(1,11) 1000 zeros(1,9)]; % old single initz for R

tic;
[task_mat] = gen_param();
fprintf('Time taken for task matrix build : %f \n',toc);
save('task_mat.mat','task_mat');

density_vec = zeros(1,size(task_mat,1));
team_sz_vec = zeros(1,size(task_mat,1));

for i = 1:size(task_mat,1) 
    t_1 = tic;
    fprintf('Working for the initial skill vector # %d :\n',i);
    R = task_mat(i,:)
    % Label Propagation
    [M,R,S,K,qual_auth_names,idx] = hyperagent_newest(R,K,alpha);
    % MM Algorithm Run
    [S_sub,S,U,x_star] = MM(M,R,S,K,qual_auth_names,idx);
    team_sz_vec(1,i) = sum(max(S_sub,[],1));
    density_vec(1,i) = size(S_sub,1)/team_sz_vec(1,i);
    fprintf('Time taken for task # %d : %f \n',i,toc-t_1);
    save('team_sz_vec.mat','team_sz_vec');
    save('density_vec.mat','density_vec');
end
team_sz_vec
density_vec



% Density (# of Nodes/ # of Edges) Curve V/S # of Skills for a given K

for N_skill = 1:22
    
end

% Team Size Curve V/S # of Skills for a given K


end
