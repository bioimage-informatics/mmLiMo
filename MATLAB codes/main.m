function main

%% Parameters & folders
parameter.sample = 'E5.5';
% parameter.sample = 'E6.5';
% parameter.sample = 'Beads1';
% parameter.sample = 'Beads2';

% Pattern list: 1~10
parameter.patterns = [1, 3, 8, 10];

% Dilation list: 2 is recomended
parameter.dil_ratios = 1:0.5:2;

% Laser emissions
parameter.emission_list = {'left-3', 'right-3', 'left0', 'right0', 'left+3', 'right+3'};

% Folders for input data
switch parameter.sample
    case 'E5.5'
        folder.data = 'E:\Azuma\SPIM\Kaneshiro\Data\E5.5H2BGFP\GFP';
        z=74;
        parameter.r=2048; parameter.c=2048;
        parameter.s=16;
    case 'E6.5'
        folder.data = 'E:\Azuma\SPIM\Kaneshiro\Data\E6.5H2BGFP\GFP';
        z=60;
        parameter.r=2048; parameter.c=2048;
        parameter.s=16;
    case 'Beads1'
        folder.data = 'E:\Azuma\SPIM\Kaneshiro\Data\Beads\hc_raw32_stacks-sample01-area01';
        z=100;
        parameter.emission_list = {'beads'};
        parameter.r=1024; parameter.c=512;
        parameter.s=32;
    case 'Beads2'
        folder.data = 'E:\Azuma\SPIM\Kaneshiro\Data\Beads\hc_raw32_stacks-sample02-area01';
        z=100;
        parameter.emission_list = {'beads'};
        parameter.r=1024; parameter.c=512;
        parameter.s=32;
end
folder.result = strrep(folder.data, 'Data', 'Result_new');

% Folders for output data
parameter.zList = 0:z;
folder.img= [folder.result, '\Img'];
folder.tilt_img = [folder.result, '\Img_tilted'];
folder.mask = [folder.result, '\Mask'];
folder.param = [folder.result, '\Parameter'];
folder.mip = [folder.result, '\MIP'];
folder.fig = [folder.result, '\Figures'];

% Imaging parameter
parameter.dxy = 0.325;

%% Image Read
read_image(parameter, folder)

%% Estimation of the location of laser lines
estimate_laser_lines(parameter, folder)

%% Subtraction to background suppression
subtraction(parameter, folder)

%% Fusion of all tilt angles to remove the shadowing artifacts
fuse_directions(parameter, folder)

%% MIP (For comparison, not necessary)
mip(parameter, folder)


