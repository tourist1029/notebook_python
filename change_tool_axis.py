## -*- coding: utf-8 -*-

import os
import re
import math
import shutil

from tkinter import *
import tkinter.filedialog

#import numpy as np


#设置正则表达式匹配公式
#一共有几种格式，GOTO模式，FROM, GOHOME(目前知道的)

reg_goto_pattern = r'GOTO/([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+),([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+),([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+)(?:,([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+),([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+),([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+)\n|\n)'
reg_from_pattern = r'FROM/([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+),([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+),([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+)(?:,([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+),([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+),([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+)\n|\n)'
reg_gohome_pattern = r'GOHOME/([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+),([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+),([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+)(?:,([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+),([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+),([+-]?[0-9]+\.?[0-9]*|[0-9]*\.?[0-9]+)\n|\n)'

pattern_goto = re.compile(reg_goto_pattern)
pattern_from = re.compile(reg_from_pattern)
pattern_gohome = re.compile(reg_gohome_pattern)

G_x_value = []
G_y_value = []
G_z_value = []
G_I_value = []
G_J_value = []
G_K_value = []

all_write_new = []




def read_cls_files(filename):
    try:
        read_file = open(filename, 'r')
        allcontents = read_file.readlines()
        f_len = len(allcontents)
        num = 0
        while num < f_len:
            get_goto_match = pattern_goto.match(allcontents[num])
            get_from_match = pattern_from.match(allcontents[num])
            get_gohome_match = pattern_gohome.match(allcontents[num])
            

            if (get_goto_match):
                get_x = get_goto_match.group(1)
                get_y = get_goto_match.group(2)
                get_z = get_goto_match.group(3)
                if (get_goto_match.group(4) != None):
                    get_I = get_goto_match.group(4)
                    get_J = get_goto_match.group(5)
                    get_K = get_goto_match.group(6)

                    new_I = '-' + get_I
                    new_J = '-' + get_J
                    new_K = '-' + get_K

                    #要替换的字符串格式
                    strr = 'GOTO/' + get_x + ',' + get_y + ',' + get_z + ',' + new_I + ',' + new_J + ',' + new_K
                    print('测试字符串为： ', strr)
                    #进行刀轴矢量替换
                    convert_content = pattern_goto.sub(strr, allcontents[num])
                    all_write_new.append(convert_content + '\n')
                    num = num + 1
                
                print("match type is GOTO:")
                # print('X= ', get_x)
                # print('Y= ', get_y)
                # print('Z= ', get_z)
                # print('I= ', get_I)
                # print('J= ', get_J)
                # print('K= ', get_K)
                



            if (get_from_match):
                get_x = get_from_match.group(1)
                get_y = get_from_match.group(2)
                get_z = get_from_match.group(3)
                if (get_from_match.group(4) != None):
                    get_I = get_from_match.group(4)
                    get_J = get_from_match.group(5)
                    get_K = get_from_match.group(6)

                    new_I = '-' + get_I
                    new_J = '-' + get_J
                    new_K = '-' + get_K

                    strr = 'FROM/' + get_x + ',' + get_y + ',' + get_z + ',' + new_I + ',' + new_J + ',' + new_K
                    #print('test is ', strr)
                    #进行刀轴矢量替换
                    convert_content = pattern_from.sub(strr, allcontents[num])
                    #print('替换后的为： ' + convert_content)
                    all_write_new.append(convert_content + '\n')
                    num = num + 1
                    

                print("match type is FROM:")
                # print('X= ', get_x)
                # print('Y= ', get_y)
                # print('Z= ', get_z)
                # print('I= ', get_I)
                # print('J= ', get_J)
                # print('K= ', get_K)


            if(get_gohome_match):
                get_x = get_gohome_match.group(1)
                get_y = get_gohome_match.group(2)
                get_z = get_gohome_match.group(3)
                if (get_gohome_match.group(4) != None):
                    get_I = get_gohome_match.group(4)
                    get_J = get_gohome_match.group(5)
                    get_K = get_gohome_match.group(6)

                    new_I = '-' + get_I
                    new_J = '-' + get_J
                    new_K = '-' + get_K

                    strr = 'GOHOME/' + get_x + ',' + get_y + ',' + get_z + ',' + new_I + ',' + new_J + ',' + new_K

                    #进行刀轴矢量替换
                    #进行刀轴矢量替换
                    convert_content = pattern_from.sub(strr, allcontents[num])
                    all_write_new.append(convert_content + '\n')
                    num = num + 1
                
                print("match type is GOHOME:")
                # print('X= ', get_x)
                # print('Y= ', get_y)
                # print('Z= ', get_z)
                # print('I= ', get_I)
                # print('J= ', get_J)
                # print('K= ', get_K)

            all_write_new.append(allcontents[num])
            num = num + 1

            



    finally:
        read_file.close()


def write_new_cls_files(path):
    try:
        output_file = open(path, 'w+')
        for i in range(len(all_write_new)):
            output_file.writelines(all_write_new[i])

    finally:
            output_file.close()


#定义窗口，选择cls文件


def window_form():

    root = Tk()

    #定义初始化窗体的尺寸,及相关参数
    root.geometry('500x300')
    root.title('Change_toolaxis')
    write_names = []

    #打开文件
    def open_it():
        filenames = tkinter.filedialog.askopenfilenames(filetypes=[("CLS file", "*.cls"), ("all", "*.*")]) ##filenames是一个元祖类型数据
        p_temp = filenames[0].split('/')
        ff_name = p_temp[len(p_temp)-1]
        p_temp.remove(ff_name)
        select_path = '/'.join(p_temp)

        #对要操作的文件进行备份
        # for i in range(len(filenames)):
        #     ltemp = filenames[i].split('/')
        #     last_filename = ltemp[len(ltemp)-1]
        #     # ltemp.remove(last_filename)
        #     # rest_file_path = '/'.join(ltemp)
        #     # print('teh rest file is ', rest_file_path)

        #     print(last_filename)
        #     cure_names = last_filename.split('.')
        #     new_name = cure_names[0] + '_old'
        #     f_new_name = new_name + '.cls'
        #     print('the final file name is ', f_new_name)
        #     whole_new_name = select_path + '/' + f_new_name 
        #     print('the whole file is : ', whole_new_name)

        #     shutil.copyfile(filenames[i], whole_new_name)
        
        print('前端部分路径为： ', select_path)  #提取文件所在路径
        sel_path.config(text=select_path)

        if (len(filenames) != 0):
            
            for i in range(len(filenames)):
                cut_name = filenames[i].split('/')
                f_name = cut_name[len(cut_name)-1]
                cut_fname = f_name.split('.')
                new_name = cut_fname[0] + '_new'
                new_cls_name = select_path + '/' + new_name + '.cls'
                print('新的文件名为： ', new_cls_name)
                read_cls_files(filenames[i])
                write_new_cls_files(new_cls_name)


        else:
            print("没有选择要处理的文件")
        
        


    # def save_new(file_name):
    #     save_path = tkinter.filedialog.askdirectory()
    #     out_path.config(text=save_path)
    #     cut_name = file_name.split('.')
    #     the_whole_name = save_path + '/' + cut_name[0] + '_new' + '.cls'
    #     write_new_cls_files(the_whole_name)



    #定义窗口布局
    out_file_btn = Button(root, text='选择要后处理的CLS文件：', command=open_it)
    out_file_btn.grid(row=0, column=0, padx=5, pady=5, sticky=W)

    # save_file_btn = Button(root, text='选择要后处理文件的位置：', command=save_new)
    # save_file_btn.grid(row=2, column=0, padx=5, pady=5, sticky=W)

    sel_path = Label(root, text='show the select path')
    sel_path.grid(row=0, column=1, sticky=W)

    # out_path = Label(root, text='show the save path')
    # out_path.grid(row=2, column=1, sticky=W)

    root.mainloop()


if __name__ == "__main__":
    
    window_form()
    #readWholeFile('TEST77.cls')
    #print('the length of Gcode is: ' + str(len(G4_code)))
    #output_Gcode()
    
    
    print("All Things Is Done!......")


