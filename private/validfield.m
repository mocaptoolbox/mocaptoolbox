function r = validfield(fld)

fld = strrep(fld,' ','_');
fld = strrep(fld,'-','');
fld = strrep(fld,'(','');
fld = strrep(fld,')','');
fld = strrep(fld,'+','');
fld = strrep(fld,'.','');
fld = strrep(fld,'\','');
fld = strrep(fld,'*','');
fld = strrep(fld,':','');
fld = strrep(fld,'#','');

if isempty(fld)
    r = fld;
    return
end
if strcmp(fld(1),'_')
    fld(1) = '';
end
if ~isempty(str2num(fld(1)))
    fld = ['z',fld];
end
r = fld;