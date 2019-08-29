clc
clear

name = 'starbw.bmp';
name_marked = 'marked.bmp';


[marchio, snr] = detection(name, name_marked, name)

toc