'''
Created on Nov 17, 2013

@author: ankindian
'''

import sys;
import re;
import math;

def dblp_data_extracter (file_type, year_r1, year_r2, test_buf, num_of_authors):

    conf_dict = {};
    conf_list = [0 for i in range(25)];
    lines = tuple(open('conferences.txt', 'r'));
    conf_count = 0;
    
    for line in lines:
        words = line.split(',');
        # print words;
        conf_list[conf_count] = words[0];
        # print(len(words));
        for i in range(1, len(words) - 1):
            conf_dict[str(words[i]).replace("\n", "")] = conf_count;
    
        conf_count = conf_count + 1;    
    
    print conf_dict;
    
    if file_type == 'Test':
        filename = 'test.txt';
        ext = 'Testing_Stats_';
    elif file_type == 'DBLP':
        filename = 'DBLP_Hadoop_Input.txt';
        ext = 'Stats_';
    elif file_type == 'CR3':
        filename = 'CR3_stats.txt';
        ext = 'data/CR3/weighted/Output_';
        
    output_file = ext + file_type + '=' + str(num_of_authors) + '.txt';
    f = open(output_file, 'w');
    lines = tuple(open(filename, 'r'));

    num_auth = 1000000;
    author_list = [];
    collab_dict = {};
    is_abstract = 0;  
    authors = [];  
    year = 0;
    skill_list = [];
    skill_mat = [[0 for i in range(25)] for j in range(num_auth)];
    conference ='';
    
    f = (open('C:/New folder (2)/Kolda Work/For Barna/Code/Data/acm_output.txt', 'r'));
    #f = (open('test.txt', 'r'));
    f.readline();
    count_line = 0;
    while 1:
    
        count_line = count_line + 1;
        #if conference == 'ICCASA':
        if count_line > 100000000:
            break;
        
        line = f.readline();
        #print(str(line));
        if line == 0:
            break;
        
        if str(line).startswith('#@'):
            
            if is_abstract == 1 and int(year) > 2005:
                auth_tup = ''; auth_idxs = []; count = 0;
                
                for author in authors:
                    if count == 0:
                        author = author[2:]
                        
                    author.replace("\n", "");
                    
                    if author_list.count(author) > 0:
                        auth_idxs.append(author_list.index(author));
                    else:
                        # print author;
                        author_list.append(author);
                        auth_idxs.append(len(author_list) - 1);

                    if conference != '' and conf_dict.has_key(conference):
                        a_idx = author_list.index(author);
                        s_idx = int(conf_dict[conference]); 
                        skill_mat[a_idx][s_idx] = skill_mat[a_idx][s_idx] + 1;
                
                    count = count + 1;
                
                if len(auth_idxs) != 1:
                    '''
                    print auth_idxs;
                    print len(auth_idxs);
                    print author_list;
                    print collab_dict;
                    '''
                    
                    auth_sorted_idxs = sorted(auth_idxs);
                    # print auth_sorted_idxs;
                    # print len(auth_sorted_idxs);
                    for i in range(0, len(auth_sorted_idxs)):
                        auth_tup = auth_tup + str(auth_sorted_idxs[i]) + '-';
                else:
                    auth_tup = auth_tup + str(auth_idxs[0]) + '-';
                    
                
                if collab_dict.get(auth_tup) != None:
                    collab_dict [auth_tup] = str(collab_dict [auth_tup]) + ',' + str(year);
                else:
                    collab_dict [auth_tup] = year;
                    
            authors = line.replace("\n", "").split(',');
            #print(authors);
            is_abstract = 1;
            continue;             
        elif str(line).startswith('#year'):
            year = str(line).replace("\n", "");
            year = year[5:];
            is_abstract = 1;
            continue;            
        elif str(line).startswith('#conf'):
            # authors = line.split(',');
            
            conference = line.replace("\n", "");
            conference = conference[5:];            

            is_abstract = 1;
            continue;
        elif str(line).startswith('#!'):
            is_abstract = 1;
            continue;
        else:
            is_abstract = 1;
            continue;    
    
    print('-------- Writing Author List ------------');        
    #print (author_list);
    output_file = 'author_list_out.txt';
    fa = open(output_file, 'w');
    for i in range(0,len(author_list)):
        fa.write(author_list[i]+'\n');
    
    fa.close();    
    
    print('-------- Writing Collaboration Sparse Matrix, Weight & Time List ------------');
    #print (collab_dict);
    output_file = 'collab_sparse_tuples_out.txt';
    fc = open(output_file, 'w');
    output_file = 'collab_weight_out.txt';
    fw = open(output_file, 'w');
    output_file = 'collab_time_out.txt';
    ft = open(output_file, 'w');
    collab_count = 0;
    
    for key in collab_dict.keys():
        c=0;
        for ath in key.split('-'):
            if ath !='':
                c+=1;
                fc.write(str(collab_count)+','+ ath +'\n');
    
        m=0;
        for yr in str(collab_dict[key]).split(','):
            m+=1;     
            ft.write(str(collab_count) + ',' + yr + '\n');
        
        w=0;    
        if c!=0:
            w = float((math.log(float(m))+float(1))/float(c));
        fw.write(str(collab_count) + ',' + str(w) + '\n');
        collab_count+=1;
            
    fc.close();    
    fw.close();
        
    print('-------- Writing Author Skill Matrix ------------');
    #print (skill_mat);    
    output_file = 'collab_skill_mat_out.txt';
    fs = open(output_file, 'w');
    
    for i in range(0, num_auth):
        s_vector = '';
        for j in range(0,25):
            s_vector = s_vector + str(skill_mat[i][j])  +',';
    
        #print s_vector;
        fs.write(s_vector + '\n');
            
    fs.close();    
    
    return 0;    

dblp_data_extracter ('Test', 2001, 2011, 3, 4)
