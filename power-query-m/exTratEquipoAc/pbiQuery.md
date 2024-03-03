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
    //Obtem planilha do excel cujo caminho completo está no parâmetro "PastaTrabalho"
    planilha = Excel.Workbook(File.Contents(PastaTrabalho), true){[Name="Planilha1"]}[Data], 
    
    //Extrai as tags dos equipamentos
    tags = List.Select(Table.ColumnNames(planilha), each not Text.StartsWith(_, "Col")), 
    
    //Quebra a planilha, transformando as colunas em listas
    listas = Table.ToColumns(planilha), 
    
    //Seleciona os itens da lista que são as chaves
    campos = List.Alternate(listas, 1, 1, 1), 
    
    //Seleciona os itens da lista que são os valores
    valores = List.Alternate(listas, 1, 1, 0),

    //Une as listas das tags, campos e valores em uma unica tabela
    zip = Table.FromRows(List.Zip({tags, campos, valores}), {"Tag", "Campos", "Valores"}),

    //Adiciona coluna [PosicoesNulas] com as posicoes vazias da coluna [Campos]
    posicoesNulas = Table.AddColumn(zip, "PosicoesNulas", each List.PositionOf([Campos], null, List.Count([Campos]))),
    
    //Adiciona coluna [PosicoesDistintas] para eliminar campos duplicados
    posicoesDistintas = Table.AddColumn(
        posicoesNulas, 
        "PosicoesDistintas", 
            each  
                let
                    getPosicoesDistintas = (lista as list) as list =>
                        let
                            posicoes = List.Positions(lista),
                            tabela = Table.FromColumns({lista, posicoes}, {"Valor", "Posicoes"}),
                            minPosicao = Table.Group(tabela, {"Valor"}, {{"Posicao", each List.Min([Posicoes])}}),
                            posicoesDistintas = minPosicao[Posicao]
                        in
                            posicoesDistintas
                in
                    getPosicoesDistintas([Campos])

    ),

    //Adiciona coluna [PosicoesValidas] que é resultado da exclusão dos itens de [PosicoesNulas] em [PosicoesDistintas]
    posicoesValidas = Table.AddColumn(posicoesDistintas, "PosicoesValidas", each List.RemoveMatchingItems([PosicoesDistintas], [PosicoesNulas])),

    //Filtra as colunas [Campo] e [Valores] pelas [PosicoesValidas] e transforma cada item uma tabela
    tabelasExtraidas = Table.AddColumn(
        posicoesValidas, 
        "Tabelas", 
        each 
            let 
                campos = 
                    let 
                        campos = [Campos] 
                    in 
                        {"Tag"} & List.Transform([PosicoesValidas], each campos{_}),
                valores = 
                    let 
                        valores = [Valores]
                    in
                        {[Tag]} & List.Transform([PosicoesValidas], each valores{_})
            in  
                #table(campos, {valores}) 
    ),

    //Lista as tabelas
    listaTabelas = tabelasExtraidas[Tabelas],
    
    //Consolida as tabelas
    consolidaTabelas = Table.Combine(listaTabelas),
    
    //Configura os tipos de dados das colunas
    tipo = Table.TransformColumnTypes(
        consolidaTabelas,{
            {"Tag", type text}, 
            {"Local", type text}, 
            {"Em operação", type text}, 
            {"Fabricante", type text}, 
            {"Tipo", type text}, 
            {"Observações", type text}, 
            {"Cor", type text}, 
            {"Capacidade(BTU/h)", Int64.Type}, 
            {"Ano Fabricação", Int64.Type}, 
            {"Tensão (V)", type number}, 
            {"Corrente R (A)", type number}, 
            {"Corrente S (A)", type number}, 
            {"Corrente T (A)", type number}, 
            {"Inspecionado em", type date}, 
            {"Próxima inspeção", type date}, 
            {"Setpoint (°C)", Int64.Type}
        }
    )

in
    tipo
```
