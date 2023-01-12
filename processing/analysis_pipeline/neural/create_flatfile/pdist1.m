function d = pdist1(arr)
% PDIST1 calculates distances passed between every two consecutive time points in the given vector.
% Input:
%     arr - array of [n x 2] points.
% 
% Output:
%     d - array of length as input 'arr', dimension as input. First value is 0.
% 
% Usage:
%     >> d = pdist1([x y])

    % ======================  INPUT CHECK  =========================
    
    if(nargin < 1)  % Return if no input was provided
        disp('Please feed in an 2xN array of points.');
        disp('        >> help pdist1');
        return;
    end
    
    s = size(arr);
    if(~(s(1) == 2 || s(2) == 2))  % Return if wrong input was provided
        disp('Please feed in an 2xN array of points.');
        disp('        >> help pdist1');
        return;
    end
    
    % ===============================================================
    
    if(s(1) == 2)   % The array is horizontal
    	arr = arr';
    end
    
    arr2 = arr(2:end, :);
    arr = arr(1:end-1, :);
    d = ((arr(:, 1) - arr2(:, 1)).^2 + (arr(:, 2) - arr2(:, 2)).^2).^0.5;
    d = [0; d];
    if(s(1) == 2) % The array is horizontal
        d = d';
    end
    
end