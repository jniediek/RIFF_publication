function init_logfile(folder)
% JN 2019-03-06
% 

% get the current git commit ID of the code
if isunix
    [git_hash, has_uncommited] = get_riff_git_id();
    [~, hostname] = system('hostname');
    [~, username] = system('whoami');
else
    git_hash = 'git_hash_not_available';
    has_uncommited = 'git_commits_not_available';
    hostname = 'hostname_not_available';
    username = 'username_not_available';
end

log_msg(folder, 'init-log', 'logging begins');
log_msg(folder, 'hostname', deblank(hostname));
log_msg(folder, 'username', deblank(username));
log_msg(folder, 'git-hash', deblank(git_hash));

log_str = 'non-commited changes in HEAD';
if ~has_uncommited
    log_str = ['no ' log_str];
end
log_msg(folder, 'git-head', deblank(log_str));

function [hash, has_uncommited] = get_riff_git_id()
% JN 2019-03-10

[riff_folder, ~, ~] = fileparts(which('main'));
cmd = sprintf('cd %s && git rev-parse HEAD', riff_folder);
[s, hash] = system(cmd);

% JN 2019-06-06
% add check whether there are non-commited changes
cmd = sprintf('cd %s && git diff-index --quiet HEAD', riff_folder);
has_uncommited = system(cmd);

if s ~= 0
    warning('Could not get git hash!')
end