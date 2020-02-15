function ret = extract_num_logic_cells(x)
    %cell_x = table2cell(x)
    cell_x = x;
    string_cell_array = {};
    for n = 1 : length(cell_x)
        x_char = char(cell_x(n));
        split_array = strsplit(char(x_char), '/');
        string_cell_array(n) = strtrim(split_array(1))
    end
    ret = str2double(string_cell_array)
end