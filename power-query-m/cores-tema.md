Tabela para alteração dinâmica de cores.
Copie e cole no editor avanaçado.
Após carregada para o Power BI pode ser utilizada para fomatação dinâmica entre modos Light e Dark

```power-query-m
let
    coresCadastro = #table ( 
        type table [ 
            Item = text, 
            Light = text, 
            Dark = text 
        ],
        {
            { "categorical1",           "#9FBFFE", "#CDDDFE" }, 
            { "categorical2",           "#6D9DFD", "#9FBFFE" }, 
            { "categorical3",           "#407FFC", "#6D9DFD" }, 
            { "categorical4",           "#0E5DFC", "#407FFC" }, 
            { "categorical5",           "#034AD8", "#0E5DFC" }, 
            { "categorical6",           "#835FF2", "#835FF2" }, 
            { "categorical7",           "#FDAD0D", "#FDBE3F" }, 
            { "categorical8",           "#F55902", "#FE8F53" }, 
            { "foregroundPrimary",      "#3D3D3D", "#F5F5F5" }, 
            { "foregroundSecondary",    "#575757", "#D1D1D1" }, 
            { "foregroundTerciary",     "#6E6E6E", "#9E9E9E" }, 
            { "foregroundQuartiary",    "#9E9E9E", "#6E6E6E" }, 
            { "backgroundPrimary",      "#FFFFFF", "#242424" }, 
            { "backgroundTerciary",     "#F5F5F5", "#1A1A1A" }, 
            { "badForeground",          "#D40202", "#FE9F9F" }, 
            { "badBackground",          "#FFCCCC", "#9D0101" }, 
            { "goodForeground",         "#029602", "#03FC03" }, 
            { "goodBackground",         "#DCFFDC", "#014101" }, 
            { "alertForeground",        "#D48E02", "#332200" }, 
            { "alertBackground",        "#FFF6E6", "#FDAD0D" }, 
            { "minimum",                "#FDBE3F", "#FDBE3F" }, 
            { "center",                 "#0D9DA5", "#0D9DA5" }, 
            { "maximum",                "#330DA5", "#330DA5" }
        } 
    ),
    unpivot = Table.UnpivotOtherColumns ( coresCadastro, { "Item" }, "Modo", "Hex" )
in
    unpivot
```
