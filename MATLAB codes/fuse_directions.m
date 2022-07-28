function fuse_directions(parameter, folder)

for dil_ratio = parameter.dil_ratios
    for pattern=parameter.patterns
        folder.subtraction = [folder.result, '\Subtraction\Pattern', num2str(pattern), '\LaserWidth', num2str(dil_ratio)];
        folder.recon = [folder.result, '\Reconstruction\Pattern', num2str(pattern), '\LaserWidth', num2str(dil_ratio)];
        folder.eval = [folder.result, '\Evaluation\Pattern', num2str(pattern), '\LaserWidth', num2str(dil_ratio)];
        folder.tiff = [folder.result, '\Tiff\Pattern', num2str(pattern), '\LaserWidth', num2str(dil_ratio)];
        recon = zeros([parameter.r, parameter.c, 1, length(parameter.zList), length(parameter.emission_list)]);
%         parfor e = 1:length(parameter.emission_list)
        for e = 1:length(parameter.emission_list)
            emission = parameter.emission_list{e};
            % Load
            the_syn = zeros(parameter.r, parameter.c, parameter.s, length(parameter.zList));
            for zz = 1:length(parameter.zList)
                filename = [folder.subtraction, '\', emission, '\Z', num2str(zz, '%03u')];
                temp = load(filename);
                the_syn(:,:,:,zz) = temp.stack;
            end
            the_syn = max(the_syn, [], 3);
            % Re-rotate to recover the original orientation
            if isequal(emission, 'left-3') || isequal(emission, 'right-3')
                the_syn = arrayfun(@(x) imrotate(the_syn(:,:,:,x), 3, 'crop'), 1:length(parameter.zList), 'UniformOutput', false);
                the_syn = cat(4, the_syn{:});
            elseif isequal(emission, 'left+3') || isequal(emission, 'right+3')
                the_syn = arrayfun(@(x) imrotate(the_syn(:,:,:,x), -3, 'crop'), 1:length(parameter.zList), 'UniformOutput', false);
                the_syn = cat(4, the_syn{:});
            end
            recon(:,:,:,:,e) = the_syn;
            % MIP at each direction and save
            each_angle_dir = [folder.recon, '\Each_angle_MIP\', emission];
            mkdir(each_angle_dir)
            parfor zz = 1:length(parameter.zList)
                filename = [each_angle_dir, '\Z', num2str(zz, '%03u')];
                parsaveStack(filename, the_syn(:,:,:,zz));
            end
        end
        % MIP
        recon_mip = squeeze(max(recon, [], 5));

        % Normalization by dividing with the maximum value
        weighted_recon = recon;
        for zz=1:size(recon, 4)
            temp_recon = arrayfun(@(x) weighted_recon(:,:,:,zz,x) / max(weighted_recon(:,:,:,zz,x), [], 'all'), 1:size(weighted_recon, 5), 'UniformOutput', false);
            weighted_recon(:,:,:,zz,:) = cat(5, temp_recon{:});
        end
        recon_mip_norm = squeeze(max(weighted_recon, [], 5));

        % save
        all_angle_dir = [folder.recon, '\All_angles'];
        all_angle_mip_dir = [folder.recon, '\All_angles_MIP'];
        all_angle_mip_norm_dir = [folder.recon, '\All_angles_MIP_Norm'];
        mkdir(all_angle_dir);
        mkdir(all_angle_mip_dir);
        mkdir(all_angle_mip_norm_dir);
        parfor zz = 1:length(parameter.zList)
            % all
            filename = [all_angle_dir, '\Z', num2str(zz, '%03u')];
            parsaveStack(filename, recon(:,:,:,zz));% r, c, slice, z, emission
            % max
            filename = [all_angle_mip_dir, '\Z', num2str(zz, '%03u')];
            parsaveStack(filename, recon_mip(:,:,zz));% r, c, z
            % norm
            filename = [all_angle_mip_norm_dir, '\Z', num2str(zz, '%03u')];
            parsaveStack(filename, recon_mip_norm(:,:,zz));% r, c, z
        end
        
        % save as tiff files
        stackWrite(recon_mip, [folder.tiff, '\all_angles_mip']);
        stackWrite(recon_mip_norm, [folder.tiff, '\all_angles_mip_norm']);
    end
end