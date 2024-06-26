Este script extrai o conteúdo do modelo do PBIX incluindo:

- Tabelas
- Colunas
- Ordenação das colunas
- Relacionamentos e cardinalidade
- Medidas e suas expressões
- Colunas calculadas
- Grupos de cálculos
- Formatos de medidas e colunas

Instruções
1. Faça o download do DAX Studio disponível neste [link](https://daxstudio.org/);  
2. Abra o PBIX desejado no Power BI Dektop;  
3. Com o Power BI Desktop vá até a guia `Ferramentas Externas` e clique em `DAX Studio`
4. O DAX Studio irá se abrir
5. Copie o código abaixo e cole na área da query no DAX Studio
6. Na barra de opções superior do DAX Studio, na divisão `Output` clique em `Results` e escolha a opção `Static`
7. Clique em `Run` na barra de navegação ou pressione `F5` no teclado
8. Escolha o local onde queira salvar o arquivo extraído contendo as tabelas com o conteúdo do seu modelo.


```dax

// Script criado por Alison Pezzott em 16 de junho de 2024 para utilização no DAX Studio
// para extração do modelo do arquivo .PBIX


DEFINE
    
    VAR __tabelas = INFO.TABLES ()
    
    VAR __colunas =
        FILTER (
            INFO.COLUMNS (),
            NOT CONTAINSSTRING (
                [ExplicitName],
                "RowNumber"
            )
        )
        
    VAR __medidas = INFO.MEASURES ()
    
    VAR __formatos = INFO.FORMATSTRINGDEFINITIONS ()
    
    VAR __relacionamentos = INFO.RELATIONSHIPS ()
    
    VAR __gruposCalculos = INFO.CALCULATIONGROUPS ()
    
    VAR __itensCalculos = INFO.CALCULATIONITEMS ()
    
    VAR __tabelaFonteMedidas =
        ADDCOLUMNS (
            __medidas,
            "Tabela",
                VAR __TabelaID = [TableID]
                RETURN
                    MAXX (
                        FILTER (
                            __tabelas,
                            [ID] = __TabelaID
                        ),
                        [Name]
                    ),
            "Formato",
                VAR __MedidaID = [ID]
                RETURN
                    MAXX (
                        FILTER (
                            __formatos,
                            [ObjectID] = __MedidaID
                        ),
                        [Expression]
                    )
        )
        
    VAR __resultMedidas =
        SELECTCOLUMNS (
            __tabelaFonteMedidas,
            "Tabela", [Tabela],
            "Medida", [Name],
            "Expressao", [Expression],
            "Formato", [FormatString],
            "EstaOculto", [IsHidden],
            "Descricao", [Description],
            "Tipo",
                SWITCH (
                    [DataType],
                    2, "String",
                    6, "Integer",
                    8, "Double",
                    9, "DateTime",
                    10, "Currency",
                    11, "Boolean"
                ),
            "Pasta", [DisplayFolder]
        )
        
    VAR __tabelaFonteColunas =
        ADDCOLUMNS (
            __colunas,
            "TabelaNome",
                VAR __TabelaID = [TableID]
                RETURN
                    MAXX (
                        FILTER (
                            __tabelas,
                            [ID] = __TabelaID
                        ),
                        [Name]
                    )
        )
        
    VAR __resultColunas =
        SELECTCOLUMNS (
            __tabelaFonteColunas,
            "Tabela", [TabelaNome],
            "Coluna",
                COALESCE (
                    [ExplicitName],
                    [InferredName]
                ),
            "OrdenadaPor",
                VAR __OrderID = [SortByColumnID]
                RETURN
                    MAXX (
                        FILTER (
                            __tabelaFonteColunas,
                            [ID] = __OrderID
                        ),
                        [ExplicitName]
                    ),
            "Formato",
                COALESCE (
                    [FormatString],
                    "String"
                ),
            "Pasta", [DisplayFolder],
            "EstaOculto", [IsHidden],
            "Expressao", [Expression]
        )
        
    VAR __tabelaFonteRelacionamentos =
        ADDCOLUMNS (
            __relacionamentos,
            "DeTabela",
                VAR __DeTabela = [FromTableID]
                RETURN
                    MAXX (
                        FILTER (
                            __tabelaFonteColunas,
                            [TableID] = __DeTabela
                        ),
                        [TabelaNome]
                    ),
            "ParaTabela",
                VAR __ParaTabela = [ToTableID]
                RETURN
                    MAXX (
                        FILTER (
                            __tabelaFonteColunas,
                            [TableID] = __ParaTabela
                        ),
                        [TabelaNome]
                    ),
            "DeColuna",
                VAR __DeColuna = [FromColumnID]
                RETURN
                    MAXX (
                        FILTER (
                            __tabelaFonteColunas,
                            [ID] = __DeColuna
                        ),
                        COALESCE (
                            [ExplicitName],
                            [InferredName]
                        )
                    ),
            "ParaColuna",
                VAR __ParaColuna = [ToColumnID]
                RETURN
                    MAXX (
                        FILTER (
                            __tabelaFonteColunas,
                            [ID] = __ParaColuna
                        ),
                        COALESCE (
                            [ExplicitName],
                            [InferredName]
                        )
                    )
        )
        
    VAR __resultRelacionamentos =
        SELECTCOLUMNS (
            __tabelaFonteRelacionamentos,
            "DeTabela", [DeTabela],
            "DeColuna", [DeColuna],
            "DeCardinalidade",
                IF (
                    [FromCardinality] = 2,
                    "*",
                    [FromCardinality]
                ),
            "De",
                "'" & [DeTabela] & "'" & "[" & [DeColuna] & "]",
            "ParaTabela", [ParaTabela],
            "ParaColuna", [ParaColuna],
            "ParaCardinalidade",
                IF (
                    [ToCardinality] = 2,
                    "*",
                    [ToCardinality]
                ),
            "Para",
                "'" & [ParaTabela] & "'" & "[" & [ParaColuna] & "]",
            "EstaAtivo", [IsActive],
            "Sentido",
                IF (
                    [CrossFilteringBehavior] = 2,
                    "Ambos",
                    "Único"
                ),
            "DePara",
                VAR __De = "'" & [DeTabela] & "'" & "[" & [DeColuna] & "]"
                VAR __Para = "'" & [ParaTabela] & "'" & "[" & [ParaColuna] & "]"
                VAR __DeCardinalidade =
                    IF (
                        [FromCardinality] = 2,
                        "*",
                        [FromCardinality]
                    )
                VAR __ParaCardinalidade =
                    IF (
                        [ToCardinality] = 2,
                        "*",
                        [ToCardinality]
                    )
                VAR __Flecha =
                    IF (
                        [CrossFilteringBehavior] = 2,
                        "<->",
                        "<-"
                    )
                VAR __Espaco = " "
                RETURN
                    __De & __Espaco & __deCardinalidade & __Espaco & 
                    	__Flecha & __espaco & __ParaCardinalidade & __Espaco & __Para
        )
        
    VAR __tabelaFonteItensCalculos =
        ADDCOLUMNS (
            ADDCOLUMNS (
                __itensCalculos,
                "TabelaID",
                    VAR __GrupoCalculo_ID = [CalculationGroupID]
                    RETURN
                        MAXX (
                            FILTER (
                                __gruposCalculos,
                                [ID] = __GrupoCalculo_ID
                            ),
                            [TableID]
                        ),
                "Precedencia",
                    VAR __GrupoCalculo_ID = [CalculationGroupID]
                    RETURN
                        MAXX (
                            FILTER (
                                __gruposCalculos,
                                [ID] = __GrupoCalculo_ID
                            ),
                            [Precedence]
                        )
            ),
            "GrupoCalculo",
                VAR __Tabela_ID = [TabelaID]
                RETURN
                    MAXX (
                        FILTER (
                            __tabelas,
                            [ID] = __Tabela_ID
                        ),
                        [Name]
                    ),
            "Formato",
                VAR __Formato_ID = [FormatStringDefinitionID]
                RETURN
                    MAXX (
                        FILTER (
                            __formatos,
                            [ID] = __Formato_ID
                        ),
                        [Expression]
                    ),
            "ColunaGrupoCalculo",
                VAR __Tabela_ID = [TabelaID]
                VAR __Coluna_ID =
                    MINX (
                        FILTER (
                            __colunas,
                            [TableID] = __Tabela_ID
                        ),
                        [ID]
                    )
                RETURN
                    MAXX (
                        FILTER (
                            __colunas,
                            [ID] = __Coluna_ID
                        ),
                        COALESCE (
                            [ExplicitName],
                            [InferredName]
                        )
                    ),
            "ColunaOrdinal",
                VAR __Tabela_ID = [TabelaID]
                VAR __Coluna_ID =
                    MAXX (
                        FILTER (
                            __colunas,
                            [TableID] = __Tabela_ID
                        ),
                        [ID]
                    )
                RETURN
                    MAXX (
                        FILTER (
                            __colunas,
                            [ID] = __Coluna_ID
                        ),
                        COALESCE (
                            [ExplicitName],
                            [InferredName]
                        )
                    )
        )
        
    VAR __resultGruposCalculos =
        SELECTCOLUMNS (
            __tabelaFonteItensCalculos,
            "GrupoCalculo", [GrupoCalculo],
            "Precedencia", [Precedencia],
            "ItemCalculo", [Name],
            "Expressao", [Expression],
            "Formato", [Formato],
            "Ordinal", [Ordinal],
            "ColunaGrupoCalculo", [ColunaGrupoCalculo],
            "ColunaOrdinal", [ColunaOrdinal]
        )
        

EVALUATE
	__resultMedidas
ORDER BY
    [Tabela] ASC,
    [Medida] ASC

EVALUATE
	__resultColunas
ORDER BY
    [Tabela] ASC,
    [Coluna] ASC

EVALUATE
	__resultRelacionamentos
ORDER BY [DePara] ASC

EVALUATE
	__resultGruposCalculos
ORDER BY
    [Precedencia] ASC,
    [Ordinal] ASC
```


  
