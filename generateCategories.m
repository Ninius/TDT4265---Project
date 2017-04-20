function cat = generateCategories()
cat = {44};
cat(1) = cellstr('fileNames');
for j=0:42
    if j < 10
        prefix = '0000';
    else
        prefix = '000';
    end
    
    cat(j+2) = cellstr(strcat(prefix, num2str(j)));
end
cat = cellstr(cat);
end