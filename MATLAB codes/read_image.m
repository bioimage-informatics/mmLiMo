function read_image(parameter, folder)
%READ_IMAGE

for e = 1:length(parameter.emission_list)
    emission = parameter.emission_list{e};
    switch emission
        case 'left-3'
            pos = 1:parameter.s;
        case 'right-3'
            pos = parameter.s+1:parameter.s*2;
        case 'left0'
            pos = parameter.s*2+1:parameter.s*3;
        case 'right0'
            pos = parameter.s*3+1:parameter.s*4;
        case 'left+3'
            pos = parameter.s*4+1:parameter.s*5;
        case 'right+3'
            pos = parameter.s*5+1:parameter.s*6;
        case 'beads'
            pos = 1:parameter.s;
    end
    img = zeros([parameter.r, parameter.c, length(pos), length(parameter.zList)]);
    count = 0;
    for i = parameter.zList
        count = count + 1;
        switch parameter.sample
            case {'E5.5', 'E6.5'}
                filename = [folder.data, filesep, 'lap', num2str(1, '%05u'), '_', num2str(i, '%04u'),'.tif'];
            case {'Beads1', 'Beads2'}
                filename = [folder.data, filesep, 'hc_raw32_slice', num2str(count, '%03u'),'.tiff'];
        end
        theImg = arrayfun(@(x) double(imread(filename, x)), pos, 'UniformOutput', false);
        theImg = cat(3, theImg{:});
        img(:,:,:,count) = theImg;
    end
    % save
    mkdir(folder.img);
    filename = [folder.img, '\', emission];
    parsaveStack(filename, img);
end
