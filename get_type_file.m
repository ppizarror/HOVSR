function s = get_type_file(filename, id)
% Retorna el tipo de archivo (si es NS, EW, Z) para un mismo fileid

try
    w = strsplit(filename, '_');
    fid = w{3};

    % Si el archivo tiene el mismo identificador
    if strcmp(fid, id)
        for i=1:length(w)
            if strcmp(w(i), 'N')
                s=1;
                return
            elseif strcmp(w(i), 'E')
                s=2;
                return
            elseif strcmp(w(i), 'Z')
                s=3;
                return
            end
        end
    end
catch
end
s = 0;

end