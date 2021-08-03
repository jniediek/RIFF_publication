function str_env=show_envelope(env)
% show_envelope (env) outputs a String representing the given envelope.
% str_env=show_env_list(env) returns a string representing the given envelope.

if nargout==0
   s= get(env,'Name');
   disp(s);
elseif nargout==1
  str_env=get(env,'Name');
else
      treat_error('Wrong use of show_envelope(env)');
end
    
