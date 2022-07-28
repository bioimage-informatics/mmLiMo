function subtraction(parameter, folder)

for e = 1:length(parameter.emission_list)
    emission = parameter.emission_list{e};
    % Load
    filename = [folder.tilt_img, '\', emission];
    img = load(filename);
    img = img.stack;

    filename = [folder.param, '\', emission];
    temp_parameter = load(filename);
    temp_parameter = temp_parameter.stack;
    parameter.initial_offset = temp_parameter.initial_offset;

    filename = [folder.param, '\common'];
    common_parameter = load(filename);
    common_parameter = common_parameter.stack;

    % Create masks
    ini_centers = parameter.initial_offset - common_parameter.interval:common_parameter.interval:parameter.r + common_parameter.interval;
    centers = {};
    parfor n = 1:parameter.s
        the_centers = ini_centers + common_parameter.step*(n-1);
        the_centers(the_centers < 1) = [];
        the_centers(the_centers > parameter.r) = [];
        centers{n} = the_centers;
    end
    mask_ori = zeros(parameter.r,parameter.c,parameter.s);
    for n=1:parameter.s
        mask_ori(centers{n},:,n)=1;
    end
    
    % save the mask
    mkdir(folder.mask);
    filename = [folder.mask, '\', emission];
    parsaveStack(filename, mask_ori);

    for dil_ratio = parameter.dil_ratios
        width = round(abs(common_parameter.step*dil_ratio));
        line = ones(width, 1);
        mask = imdilate(mask_ori, line);
        for pattern=parameter.patterns
            folder.subtraction = [folder.result, '\Subtraction\Pattern', num2str(pattern), '\LaserWidth', num2str(dil_ratio)];
            syn = zeros(parameter.r,parameter.c,parameter.s,length(parameter.zList));
            s = parameter.s;
%             parfor n=1:s
            for n=1:s
                the_img = img(:,:,n,:);
                if n==1
                    pre_img1 = img(:,:,s,:);
                    pre_img2 = img(:,:,s-1,:);
                    pre_img3 = img(:,:,s-2,:);
                elseif n==2
                    pre_img1 = img(:,:,n-1,:);
                    pre_img2 = img(:,:,s,:);
                    pre_img3 = img(:,:,s-1,:);
                elseif n==3
                    pre_img1 = img(:,:,n-1,:);
                    pre_img2 = img(:,:,n-2,:);
                    pre_img3 = img(:,:,s,:);
                else
                    pre_img1 = img(:,:,n-1,:);
                    pre_img2 = img(:,:,n-2,:);
                    pre_img3 = img(:,:,n-3,:);
                end
                if n==s
                    post_img1 = img(:,:,1,:);
                    post_img2 = img(:,:,2,:);
                    post_img3 = img(:,:,3,:);
                elseif n==s-1
                    post_img1 = img(:,:,s,:);
                    post_img2 = img(:,:,1,:);
                    post_img3 = img(:,:,2,:);
                elseif n==s-2
                    post_img1 = img(:,:,s-1,:);
                    post_img2 = img(:,:,s,:);
                    post_img3 = img(:,:,1,:);
                else
                    post_img1 = img(:,:,n+1,:);
                    post_img2 = img(:,:,n+2,:);
                    post_img3 = img(:,:,n+3,:);
                end
                % mask
                the_mask = mask(:,:,n);
                the_mask = repmat(the_mask, [1,1,1,length(parameter.zList)]);
                center = the_img .* the_mask;
                pre1 = pre_img1 .* the_mask;
                pre2 = pre_img2 .* the_mask;
                pre3 = pre_img3 .* the_mask;
                post1 = post_img1 .* the_mask;
                post2 = post_img2 .* the_mask;
                post3 = post_img3 .* the_mask;
                % subtraction
                switch pattern
                    case 1
                        syn(:,:,n,:) = center;
                    case 2
                        fore = center + pre1 + post1;
                        back = pre2 + post2;
                        syn(:,:,n,:) = fore - back;
                    case 3
                        fore = center + pre1 + post1;
                        back = 1.5*pre2 + 1.5*post2;
                        syn(:,:,n,:) = fore - back;
                    case 4
                        fore = center;
                        back = 0.5*pre1 + 0.5*post1;
                        syn(:,:,n,:) = fore - back;
                    case 5
                        fore = center + pre1 + post1 + pre2 + post2;
                        back = pre3 + post3;
                        syn(:,:,n,:) = fore - back;
                    case 6
                        fore = center + pre1 + post1;
                        back = pre2 + post2 + pre3 + post3;
                        syn(:,:,n,:) = fore - back;
                    case 7
                        fore = center + pre1 + post1;
                        back = pre3 + post3;
                        syn(:,:,n,:) = fore - back;
                    case 8
                        fore = center + pre1 + post1;
                        back = 1.5*pre3 + 1.5*post3;
                        syn(:,:,n,:) = fore - back;
                    case 9
                        fore = center + pre1 + post1 + pre2 + post2;
                        back = 2*pre3 + 2*post3;
                        syn(:,:,n,:) = fore - back;
                    case 10
                        fore = center + pre1 + post1 + pre2 + post2;
                        back = (5/2)*pre3 + (5/2)*post3;
                        syn(:,:,n,:) = fore - back;
                end
            end
            % save
            mkdir([folder.subtraction, '\', emission]);
            parfor zz = 1:length(parameter.zList)
                filename = [folder.subtraction, '\', emission, '\Z', num2str(zz, '%03u')];
                parsaveStack(filename, syn(:,:,:,zz));
            end
        end
    end
end


