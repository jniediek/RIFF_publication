%IS_LEGAL_FORMULA checks  if the given val is a string reprsenting a legal
%formula.
% [IS_FORMULA,FINAL_VALUE,DEF_EXIST]=IS_LEGAL_FORMULA(VAL,DEF_ARR,VAR_ARR)
% checks  if  VAL is a string reprsenting a legal formula.
%A legal formula is any mathematical expression that contains variables
%from either the def_arr or var_arr.
% input arguments:
% VAL - value checked
% DEF_ARR - a (2xn) array that holds for each variable name it's value. It
% holds the default varaibles defined by the user in the Default box
% of maestro1.
% VAR_ARR- a (2xn) array that holds for each variable name it's value.This
% array contain the variables from the var-file that was given in the
% runnung command of maestro1.
% output arguments:
% IS_FORMULA - equals 1 if this is a formula expression at all (legal or
% illegal). A formula is an expression that contains at least one letter.
% FINAL_VALUE - the calculated value of the formula after replacing every
% varaible in the expression with the matching value.
% DEF_EXIST - equals 1 if the formula contains varaibles from DEF_ARR.
function [is_formula,final_value,def_exist]=is_legal_formula(val,def_arr,var_arr)
original=val;
def_exist=0;
is_formula=0;
final_value=0;

if ~isa(val,'char')
    error('VAL must be a character type');
end
    
% checking def_arr argument
s=size(def_arr);
if ~isempty(def_arr)
    if ~(s(1)==2)
       error('DEF_ARR must be of size (2xn)');
    end
    arr_line1=def_arr(1,:);
    arr_line2=def_arr(2,:);
    s1=size(arr_line1);
    s2=size(arr_line2);
    if ~(s1==s2)
        error('DEF_ARR must contain 2 rows with the same length');
    end

    if ~(iscellstr(arr_line1))
        error('DEF_ARR first line must be a list of variable names');
    end
    for k=1:length(arr_line2)
        if ~(isscalar(arr_line2{1,k}))
            arr_line2{1,k}
            class(arr_line2{1,k})
            error('DEF_ARR second line must be a list of numbers');
        end
    end%for
end

% checking def_arr argument
s=size(var_arr);
if ~isempty(var_arr)
    if ~(s(1)==2)
       error('VAR_ARR must be of size (2xn)');
    end
    arr_line1=var_arr(1,:);
    arr_line2=var_arr(2,:);
    s1=size(arr_line1);
    s2=size(arr_line2);
    if ~(s1==s2)
        error('VAR_ARR must contain 2 rows with the same length');
    end

    if ~(iscellstr(arr_line1))
        error('VAR_ARR first line must be a list of variable names');
    end
    for k=1:length(arr_line2)
        if ~(isscalar(arr_line2{1,k}))
            error('VAR_ARR second line must be a list of numbers');
        end
    end%for
end

% calculating the formula
s=size(def_arr);
for k=1:s(2)
    rep=num2str(def_arr{2,k});
    val=strrep(val,def_arr{1,k},rep);
end
if (~(strcmp(val,original)==1))%DEFAULTS were replaced in the string
    def_exist=1;
end
if (~isempty(var_arr))
    s=size(var_arr);
    for k=1:s(2)
    rep=num2str(var_arr{2,k});
    val=strrep(val,var_arr{1,k},rep);
    end
end

try
    eval(['num=',val,';']);
catch
    return;
end

if (isempty(num) || ~(isscalar(num)==1) || iscell(num))%if this is an empty string or not a scalar
    is_formula=0;
    final_value=0;
else
    is_formula=1;
    final_value=num;
end

        