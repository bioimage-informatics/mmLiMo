function [xi,yi,zi] = get_lines(sample,the_axis)
%GET_LINE この関数の概要をここに記述
%{
dZ = 3 um
zが大きいほうが対物レンズ側だと思われる

E5.5
MaxZ = 75
90um = 45 z
120 um = 35 z
150 um = 25 z
180 um = 15 z

%}


switch sample
    case 'E5.5'
        x = [1155 1180 1192];
        y = [1474 1500 1462];
%         x = [1155 1192];
%         y = [1474 1462];
        x_range = 231;
        y_range = 308;
        switch the_axis
            case 'y'
                xi = {[x(1) x(1)], [x(2) x(2)], [x(3) x(3)]};
                yi = {[y(1)-y_range+1 y(1)+y_range], [y(2)-y_range+1 y(2)+y_range], [y(3)-y_range+1 y(3)+y_range]};
            case 'x'
                xi = {[x(1)-x_range+1 x(1)+x_range+1], [x(2)-x_range+1 x(2)+x_range+1], [x(3)-x_range+1 x(3)+x_range+1]};
                yi = {[y(1) y(1)], [y(2) y(2)], [y(3) y(3)]};
        end
        zi = {45, 35, 25};
        zi = {25, 35, 45};
%         zi = {1,2,3};
    case 'E6.5'
        switch the_axis
            case 'y'
                xi = {[1023 1451], [1412 1470], [1438 1309], [1073 1073]};
                yi = {[140 601], [680 1765], [1535 1842], [771 2001]};
            case 'x'
                xi = {[1023 1451], [1412 1470], [1438 1309], [704 1473]};
                yi = {[140 601], [680 1765], [1535 1842], [1460 1460]};
%                 xi = {[1023 1451], [1412 1442], [1438 1309], [704 1473]};
%                 yi = {[140 601], [680 1734], [1535 1842], [1460 1460]};
        end
        zi = {45, 35, 25, 15};
        zi = {15, 25, 35, 45};
%         zi = {1,2,3,4};
        
    case 'E6.5old'
        x = [1000 985 1024 1073];
        y = [1000 1187 1347 1570];
        x_range = 350;
        y_range = 500;
        switch the_axis
            case 'y'
                xi = {[x(1) x(1)], [x(2) x(2)], [x(3) x(3)], [x(4) x(4)]};
                yi = {[y(1)-y_range-300+1 y(1)+y_range+300], [y(2)-y_range-200+1 y(2)+y_range+200], ...
                    [y(3)-y_range-100+1 y(3)+y_range+100], [y(4)-y_range+1 y(4)+y_range]};
            case 'x'
                xi = {[x(1)-x_range-150+1 x(1)+x_range+150], [x(2)-x_range-100+1 x(2)+x_range+100], ...
                    [x(3)-x_range-50+1 x(3)+x_range+50], [x(4)-x_range+1 x(4)+x_range]};
                yi = {[y(1) y(1)], [y(2) y(2)], [y(3) y(3)], [y(4) y(4)]};
        end
        zi = {45, 35, 25, 15};
%         zi = {1,2,3,4};
end





%{
switch sample
    case 'E5.5'
        switch the_axis
            case 'y'
                xi = {[1155 1155], [1250 1250], [1190 1190]};
                yi = {[1151 1750], [1201 1800], [1151 1750]};
            case 'x'
                xi = {[951 1350], [1001 1400], [1001 1400]};
                yi = {[1481 1481], [1600 1600], [1500 1500]};
        end
        zi = {45, 35, 25};
        zi = {1,2,3};
    case 'E6.5'
        switch the_axis
            case 'y'
                xi = {[1446 1446], [1425 1425], [1376 1376], [1035 1035]};
                yi = {[601 1800], [701 1900], [701 1900], [701 1900]};
            case 'x'
                xi = {[551 1500], [601 1350], [601 1450], [651 1400]};
                yi = {[1000 1000], [337 337], [1608 1608], [1550 1550]};
        end
        zi = {45, 35, 25, 15};
        zi = {1,2,3,4};
end
%}