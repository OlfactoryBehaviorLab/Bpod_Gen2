function root_folder = GetProtocols
global BpodSystem



root_folder_path = BpodSystem.SystemSettings.ProtocolFolder;


root_folder = dir(root_folder_path);

% folder_mask = [root_folder.isdir];
% sub_folders = root_folder(folder_mask);
% sub_folders = sub_folders(3:end); % Always skip '.' and '..'

    root_folder = walk_dir(root_folder(1));
end


function directory = walk_dir(directory)
    directory.has_protocol = false;
    directory.subdirectory = {};

    folder_name = directory.name;
    folder_path = directory.folder; 
    disp(['In folder: ' folder_name]);
    combined_path = fullfile(folder_path, folder_name);

    folder_contents = dir(combined_path);
    folder_mask = [folder_contents.isdir];
    folders = folder_contents(folder_mask);
    folders = folders(3:end); % Always skip '.' and '..'
    files = folder_contents(~folder_mask);
    fprintf('Folder \"%s\" has %d subfolders we need to check!\n', folder_name, length(folders));

    for i = 1:length(folders)
        return_directory = walk_dir(folders(i));
        if or(return_directory.has_protocol, ~isempty(return_directory.subdirectory))
            directory.subdirectory = [directory.subdirectory return_directory];
        end
    end

    good_files = check_files(files, folder_name); % Check if this folder has a protocol
    if(~isempty(good_files)) % If a protocol file was found
        disp(['Folder ' folder_name ' has a protocol!']);
        directory.has_protocol = true; % Save the protocol file
    end

    return

end

function protocol_files = check_files(files, folder_name)
protocol_files = {};

for i = 1:length(files)
    actual_name = files(i).name;
    expected_name = [folder_name '.m'];

    if(strcmp(actual_name, expected_name))
        protocol_files = [protocol_files files(i)];
    end
end

end