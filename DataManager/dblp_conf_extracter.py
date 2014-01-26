'''
Created on Nov 21, 2013

@author: ankindian
'''

import sys;
import re;

def dblp_conf_extracter (file_type, year_r1, year_r2, test_buf, num_of_authors):

    conf_list = [];
        
    output_file = 'conference_out.txt';
    fw = open(output_file, 'w');    
        
    f = (open('C:/New folder (2)/Kolda Work/For Barna/Code/Data/acm_output.txt', 'r'));
    f.readline();
    count_line = 0;
    while 1:
    
        count_line = count_line + 1;
        if count_line > 10000:
            break;
        
        line = f.readline();
        if line == 0:
            break;
        
        if str(line).startswith('#conf'):
            
            conference = line.replace("\n", "");
            conference = conference[5:];            
            
            if conf_list.count(conference) == 0 and conference != '':
                conf_list.append(conference);
                fw.write(conference + '\n')
                #print(conference);
            
            continue;
        else:
            continue;
            
    f.close();
    fw.close();
    
    print('$$$$$$$$$$$$$$$');        
    #print (conf_list);
    print len(conf_list);
    
    return 0;    

dblp_conf_extracter ('Test', 2001, 2011, 3, 4)

