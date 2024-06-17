# Tratamento de base com M avançado
> Exemplo: Equipamentos de ar condicionado <br>
> Atualizado em 2024-03-02

## Descrição
O código abaixo trata uma base extremamente bagunçada e que cresce para a direita, porém apresenta a carcaterística de possuir chave valor.
Neste código, foi empregado o código sem hard code ou seja sem referência de colunas da base. Além disso este códgo tem a capacidade de aceitar novas colunas (equipamentos) sem a necessidade de manutenção.<br>
> Baixe aqui o arquivo base para o tratamento: [Link](https://github.com/alisonpezzott/powerbi/blob/main/power-query-m/etlExamples/2024-03-04-fact_inspections/BaseDados.xlsx) <br>
> Acesse aqui o vídeo sobre este case: [Video](https://youtu.be/hHNNPbg0v9M)

## Código M
```power-query-m
let
    //Extrai os dados da planilha cujo endereço está no parâmetro arquivo
    sheet = Excel.Workbook(File.Contents(Arquivo), true, true)
        {[Item = "Planilha1", Kind = "Sheet"]}
        [Data], 
    
    //Extrai a lista com as tags a partir dos nomes das colunas 
    tags = List.Select(Table.ColumnNames(sheet), each not Text.StartsWith(_, "Col")),
    
    //Extrai lista a partir das colunas
    lists = Table.ToColumns(sheet),
    
    //Seleciona os itens que correpondem aos campos
    fields = List.Alternate(lists, 1, 1, 1),
    
    //Seleciona os itens que correspondem aos valores
    values = List.Alternate(lists, 1, 1),
    
    //Gera uma tabela a partir das listas tags, fields e values
    tbFromColumns = Table.FromColumns(
        {tags, fields, values},
        {"Tag", "Field", "Value"}
    ),
    
    //Adiciona uma coluna com as posições nulas dos campos
    addNullPositions = Table.AddColumn(
        tbFromColumns,
        "NullPositions",
        each List.PositionOf([Field], null, List.Count([Field]))
    ),
    
    //Adiciona uma coluna com as posições distintas
    addDistinctPositions = Table.AddColumn(
        addNullPositions,
        "DistinctPositions",
        each
            let
                getDistinctPositions = (list as list) as list =>
                    let
                        positions = List.Positions(list),
                        table = Table.FromColumns(
                            {list, positions},
                            {"Value", "Position"}
                        ),
                        output = Table.Group(
                            table,
                            {"Value"},
                            {{"Position", each List.Min([Position]), type number}}
                        )[Position]
                    in
                        output
            in
                getDistinctPositions([Field])
    ),
    
    //Adiciona uma coluna contendo apenas as posições válidas que foi gerada
    //excluindo da lista das posições distintas, a lista das posições nulas.
    addPositions = Table.AddColumn(
        addDistinctPositions,
        "Positions",
        each List.RemoveMatchingItems([DistinctPositions], [NullPositions])
    ),
    
    //Adiciona uma coluna com os campos distintos e não nulos
    addFieldsOk = Table.AddColumn(
        addPositions,
        "FieldsOk",
        each
            let
                field = [Field]
            in
                {"Tag"} & List.Transform([Positions], each field{_})
    ),
    
    //Adiciona uma coluna com os valores distintos e não nulos
    addValuesOk = Table.AddColumn(
        addFieldsOk,
        "ValueOk",
        each
            let
                value = [Value]
            in
                {[Tag]} & List.Transform([Positions], each value{_})
    ),
    
    //Adiciona uma coluna contendo as tabelas geradas a partir dos campos e valores
    addExtractTables = Table.AddColumn(
        addValuesOk,
        "Tables",
        each #table([FieldsOk], {[ValueOk]})
    ),
    
    //Transforma a coluna Tables em uma lista de tabelas
    listOfTables = addExtractTables[Tables],
    
    //Consolida a lista de tabelas em uma única tabela
    consolidatedTables = Table.Combine(listOfTables),
    
    //Altera os tipos das colunas da tabela
    chagedType = Table.TransformColumnTypes(
        consolidatedTables,
        {
            {"Tag", type text},
            {"Local", type text},
            {"Em operação", type text},
            {"Tipo", type text},
            {"Fabricante", type text},
            {"Observações", type text},
            {"Inspecionado em", type date},
            {"Próxima inspeção", type date},
            {"Setpoint (°C)", type number},
            {"Corrente T (A)", type number},
            {"Corrente S (A)", type number},
            {"Corrente R (A)", type number},
            {"Tensão (V)", type number},
            {"Capacidade(BTU/h)", type number}
        }
    )

in
    chagedType
```
