lookupvalue = Table.AddColumn(
  #"Etapa Anterior",
  "NomeNovaColuna",
  let
    __outraTabela = NomeOutraTabela[[NomeColunaProcurada], [NomeColunaResultado]]
  in
    each 
      let 
        __colunaReferencia =  [NomeColunaReferencia]
      in
        Table.SelectRows(
          __outraTabela,
          each [NomeColunaProcurada] = __colunaReferencia
        )
        {0}
        [NomeColunaResultado],           
  type text //coloque o tipo correto para o caso
)

