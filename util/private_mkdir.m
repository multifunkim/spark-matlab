function [status, msg, msgid] = private_mkdir(dirPath)

status = 0; %#ok
msg = ['Failed to create the directory ', dirPath];
msgid = mfilename;

[dir, ~, ext] = fileparts(dirPath);
if ~isempty(ext)
    [status, msg, msgid] = private_mkdir(dir);
elseif (exist(dir, 'dir') || isempty(dir))
    if ~exist(dirPath, 'dir')
        [status, msg, msgid] = mkdir(dirPath);
    else
        status = 1;
    end
else
    [status, msg, msgid] = private_mkdir(dir);
    if status
        if ~exist(dirPath, 'dir')
            [status, msg, msgid] = mkdir(dirPath);
        else
            status = 1;
        end
    end
end

end