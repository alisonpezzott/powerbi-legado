# Tratamento de base com M avançado - Equipamentos de ar condicionado - 2024-03-02

O código abaixo trata uma base extremamente bagunçada e que cresce para a direita, porém apresenta a carcaterística de possuir chave valor.
Neste código, foi empregado o código sem hard code ou seja sem referência de colunas da base. Além disso este códgo tem a capacidade de aceitar novas colunas (equipamentos) sem a necessidade de manutenção.
<br>Baixe aqui o arquivo base para o tratamento: [Link](https://github.com/alisonpezzott/powerbi/blob/main/power-query-m/exTratEquipoAc/BaseDados.xlsx)
<br>Acesse aqui o vídeo sobre este case: 

```power-query-m
let
    //Obtem planilha do excel cujo caminho completo está no parâmetro "PastaTrabalho"
    planilha = Excel.Workbook(File.Contents(PastaTrabalho), true){[Name="Planilha1"]}[Data], 
    
    //Extrai as tags dos equipamentos
    tags = List.Select(Table.ColumnNames(planilha), each not Text.StartsWith(_, "Col")), 
    
    //Quebra a planilha, transformando as colunas em listas
    listas = Table.ToColumns(planilha), 
    
    //Extrai a posição da lista
    posicoes = List.Positions(listas), 
    
    //Seleciona as posicoes dos itens da lista que são as chaves
    indicesChaves = List.Select(posicoes, each Number.Mod(_, 2)=0), 
    
    //Transforma as posicoes nas chaves correspondentes das listas
    chaves = List.Transform(indicesChaves, each listas{_}), 
    
    //Seleciona as posicoes dos itens da lista que são os valores
    indicesValores = List.Select(posicoes, each Number.Mod(_, 2)=1), 
    
    //Transforma as posicoes nos valores correspondentes das listas
    valores = List.Transform(indicesValores, each listas{_}), 
    
    //Gera uma tabela a partir das listas das tags, chaves e valores
    paraTabela = Table.FromColumns({tags, chaves, valores}, {"Tag", "Chave", "Valor"}), 
    
    //Adicioona uma coluna contendo as posicoes válidas quando as chaves não estão vazias
    indicesValidos = Table.AddColumn( 
        paraTabela, 
        "indicesValidos", 
        each let 
            vazias = List.PositionOf([Chave], null, List.Count([Chave])),     //Posicoes das chaves vazias
            todas = List.Positions([Chave])                                   //Todas as posições
        in 
            List.RemoveMatchingItems(todas, vazias),                         //Remove as vazias entre todas
        type list 
    ), 
    
    //Gera um lista de tabelas para cada equipamento pois alguns não possuem todas as mesmas colunas
    listaTabelas = Table.AddColumn(
        indicesValidos, 
        "Tabelas", 
        each let 
            tag = [Tag],                                                     //Tag do equipamento
            chave = [Chave],                                                 //Lista de todas as chaves
            chaveOk = List.Transform([indicesValidos], each chave{_}),       //Chaves válidas apenas
            valor = [Valor],                                                 //Lista de todos os valores
            valorOk = List.Transform([indicesValidos], each valor{_}),       //Valores válidos apenas
            tabela = #table(chaveOk, {valorOk})                              //Tabela a partir das chaves e valores válidos
        in 
            Table.AddColumn(tabela, "Tag", each tag)                         //Adiciona a coluna Tag
    )
    [Tabelas],                                                               //Transforma a tabela em uma lista de tabelas
    
    //Faz a união de todas as tabelas
    unionTabelas = Table.Combine(listaTabelas),                              
    
    //Reordena as colunas
    reordena = Table.ReorderColumns( 
        unionTabelas, 
        { 
            "Tag", 
            "Local", 
            "Em operação", 
            "Capacidade(BTU/h)", 
            "Fabricante", 
            "Ano Fabricação", 
            "Tipo", 
            "Tensão (V)", 
            "Corrente R (A)", 
            "Corrente S (A)", 
            "Corrente T (A)", 
            "Observações", 
            "Setpoint (°C)", 
            "Inspecionado em", 
            "Próxima inspeção"
        } 
    ), 
    
    //Tipifica as colunas
    tipo = Table.TransformColumnTypes(
        reordena,{
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
            {"Ano Fabricação", type number}, 
            {"Capacidade(BTU/h)", type number}
        } 
    ) 

in
    tipo
```
