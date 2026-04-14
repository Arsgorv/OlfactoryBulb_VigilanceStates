%function to concatenate structures
function Struct=ConCatStruct(Struct_1,Struct_2)

try
    Table_1=struct2table(Struct_1);
    Table_2=struct2table(Struct_2);
    Struct=table2struct([Table_1,Table_2]);
    
catch
     f = fieldnames(Struct_1);
     for i = 1:length(f)
        Struct_2.(f{i}) = Struct_1.(f{i});
     end
     Struct = Struct_2;
end
    
end
