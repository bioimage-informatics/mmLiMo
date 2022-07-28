function mip(parameter, folder)

img = zeros([parameter.r, parameter.c, 1, length(parameter.zList), length(parameter.emission_list)]);
parfor e = 1:length(parameter.emission_list)
    emission = parameter.emission_list{e};
    % Load
    filename = [folder.img, '\', emission];
    the_img = load(filename);
    the_img = the_img.stack;
    the_img = max(the_img, [], 3);
    img(:,:,:,:,e) = the_img;
end
img_mip = squeeze(max(img, [], 5));
img_mip_norm = img_mip ./ mean(img_mip, 'all');

% save
all_angle_dir = [folder.mip, '\All_angles'];
all_angle_mip_dir = [folder.mip, '\All_angles_MIP'];
all_angle_mip_norm_dir = [folder.mip, '\All_angles_MIP_Norm'];
mkdir(all_angle_dir);
mkdir(all_angle_mip_dir);
mkdir(all_angle_mip_norm_dir);
parfor zz = 1:length(parameter.zList)
    % all
    filename = [all_angle_dir, '\Z', num2str(zz, '%03u')];
    parsaveStack(filename, img(:,:,:,zz));% r, c, slice, z, emission
    % max
    filename = [all_angle_mip_dir, '\Z', num2str(zz, '%03u')];
    parsaveStack(filename, img_mip(:,:,zz));% r, c, z
    % norm
    filename = [all_angle_mip_norm_dir, '\Z', num2str(zz, '%03u')];
    parsaveStack(filename, img_mip_norm(:,:,zz));% r, c, z
            
end
% save
folder.tiff = [folder.result, '\Tiff\MIP'];
stackWrite(img_mip, [folder.tiff, '\Image_mip']);
stackWrite(img_mip_norm, [folder.tiff, '\Image_mip_norm']);
