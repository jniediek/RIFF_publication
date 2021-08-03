% GET_FORMULA_VALUE  returns the final value of the formula. This function replace each
% varaible in the formula with the corresponding numeric value, then it
% calculates the final numeric value of the formula.
% FINAL_VALUE=GET_FORMULA_VALUE(FORMULA,DEF_ARR,VAR_ARR)
% returns the final value of the givaen formula.
% The formula expression is calculated by replacing each occurance of a
% formula with the matching value.
% input arguments:
% FORMULA - the calculated formula expression
% DEF_ARR - a (2xn) array that holds for each variable name it's value. It
% holds the default varaibles defined by the user in the Default box
% of maestro1.
% VAR_ARR- a (2xn) array that holds for each variable name it's value.This
% array contain the variables from the var-file that was given in the
% runnung command of maestro1.
% output argument:
% FINAL_VALUE - the calculated value.
function final_value=get_formula_value(formula,def_arr,var_arr)
if ~isa(formula,'char')
    error('FORMULA must be a character type');
end
s=size(def_arr);
for k=1:s(2)
    rep=num2str(def_arr{2,k});
    formula=strrep(formula,def_arr{1,k},rep);
end
if (~isempty(var_arr))
    s=size(var_arr);
    for k=1:s(2)
    rep=num2str(var_arr{2,k});
    formula=strrep(formula,var_arr{1,k},rep);
    end
end
num=str2num(formula);
final_value=num;
