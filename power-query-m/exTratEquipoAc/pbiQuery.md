# Tratamento de base com M avançado
> Exemplo: Equipamentos de ar condicionado <br>
> Atualizado em 2024-03-02

## Descrição
O código abaixo trata uma base extremamente bagunçada e que cresce para a direita, porém apresenta a carcaterística de possuir chave valor.
Neste código, foi empregado o código sem hard code ou seja sem referência de colunas da base. Além disso este códgo tem a capacidade de aceitar novas colunas (equipamentos) sem a necessidade de manutenção.<br>
> Baixe aqui o arquivo base para o tratamento: [Link](https://github.com/alisonpezzott/powerbi/blob/main/power-query-m/exTratEquipoAc/BaseDados.xlsx) <br>
> Acesse aqui o vídeo sobre este case: 

## Código M
```power-query-m
let
    //Extrai os dados do excel cujo endereços está definido no parâmetro Arquivo
    planilha = Excel.Workbook(File.Contents(Arquivo), true, true){[Item="Planilha1", Kind="Sheet"]}[Data],

    //Obtém as tags a partir da lista dos nomes das colunas da planilha
    tags = List.Select(Table.ColumnNames(planilha), each not Text.StartsWith(_,"Col")),

    //Transforma cada coluna da planilha em uma lista
    colunasEmListas = Table.ToColumns(planilha),

    //Seleciona a partir das colunasEmListas aquelas que são os campos
    campos = List.Alternate(colunasEmListas, 1, 1, 1),

    //Seleciona a partir das colunasEmListas aquelas que são os valores
    valores = List.Alternate(colunasEmListas, 1, 1, 0),

    //Gera uma tabela a partir das listas das tags, campos e valores
    tabelaDasListas = Table.FromColumns(
        {tags, campos, valores}, 
        {"Tag", "Campos", "Valores"}
    ),

    //Adiciona uma coluna contendo as PosicoesNulas dos campos
    posicoesNulas = Table.AddColumn(
        tabelaDasListas, 
        "PosicoesNulas", 
        each List.PositionOf([Campos], null, List.Count([Campos]))
    ),

    //Adiciona uma coluna contendo as PosicoesDistintas dos campos
    posicoesDistintas = Table.AddColumn(
        posicoesNulas, 
        "PosicoesDistintas", 
        each 
            let
                getPosicoesDistintas = (lista as list) as list =>
                let
                    posicoes = List.Positions(lista),
                    tabela = Table.FromColumns(
                        {lista, posicoes}, 
                        {"Valor", "Posicao"}
                    ),
                    posicoesDistintas = Table.Group(
                        tabela, 
                        {"Valor"}, 
                        {{"Posicao", each List.Min([Posicao]), type number}}
                    )
                    [Posicao]
                in
                    posicoesDistintas
            in
                getPosicoesDistintas([Campos])
    ),

    //Adiciona uma coluna removendo das PosicoesDistintas as PosicoesNulas
    posicoesValidas = Table.AddColumn(
        posicoesDistintas, 
        "PosicoesValidas", 
        each List.RemoveMatchingItems([PosicoesDistintas], [PosicoesNulas])
    ),

    //Adiciona uma coluna contendo apenas os campos válidos
    camposOk = Table.AddColumn(
        posicoesValidas, 
        "CamposOk", 
        each 
            let 
                campos = [Campos] 
            in
                {"Tag"}  
                    & List.Transform([PosicoesValidas], each campos{_})
    ),

    //Adiciona uma coluna contendo apenas os valores válidos
    valoresOk = Table.AddColumn(
        camposOk, 
        "ValoresOk", 
        each 
            let 
                valores = [Valores]
            in
                {[Tag]} & List.Transform([PosicoesValidas], each valores{_})
    ),
    
    //Adiciona uma coluna, extraindo uma tabela de cada linha
    tabelasExtraidas = Table.AddColumn(
        valoresOk, 
        "Tabelas", 
        each #table([CamposOk], {[ValoresOk]})
    ),

    //Gera uam lista de tabelas
    listaTabelas = tabelasExtraidas[Tabelas],

    //Combina a lista de tabelas
    consolidado = Table.Combine(listaTabelas),

    //Faz a tipagem das colunas
    tipoAlterado = Table.TransformColumnTypes(
        consolidado,{
            {"Tag", type text}, 
            {"Local", type text}, 
            {"Em operação", type text}, 
            {"Fabricante", type text}, 
            {"Tipo", type text}, 
            {"Observações", type text}, 
            {"Próxima inspeção", type date}, 
            {"Inspecionado em", type date}, 
            {"Setpoint (°C)", type number}, 
            {"Corrente T (A)", type number}, 
            {"Corrente S (A)", type number}, 
            {"Corrente R (A)", type number}, 
            {"Tensão (V)", type number}, 
            {"Capacidade(BTU/h)", type number}
        }
    )

in
    tipoAlterado
```
