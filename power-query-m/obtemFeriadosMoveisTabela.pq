( ano as number ) as table =>
let
    modExcel =  ( x, y ) => let m = Number.Mod ( x, y ) in if  m < 0 then m + y else m,
    pascoa =  Date.From ( 
        Number.Round (
            Number.From ( #date ( ano, 4, 1 ) ) / 7 
              +  modExcel ( 19 * modExcel ( ano, 19 ) - 7, 30 ) * 0.14, 
            0, 
            RoundingMode.Up 
        ) 
        * 7 - 6 
    ),
    feriadosMoveis = Table.FromRecords (
        {[ 
            #"Ano" = ano,
            #"Segunda-feira de Carnaval" = Date.AddDays ( pascoa, -48 ),
            #"Terça-feira de Carnaval"  =  Date.AddDays ( pascoa, -47 ),
            #"Quarta-feira de Cinzas" = Date.AddDays ( pascoa, -46 ), 
            #"Sexta-Feira Santa" = Date.AddDays ( pascoa, -2  ), 
            #"Páscoa" = pascoa,
            #"Corpus Christi" = Date.AddDays ( pascoa, 60  )
        ]},
        type table [
            Ano = Int64.Type,
            #"Segunda-feira de Carnaval" = date,
            #"Terça-feira de Carnaval" = date,
            #"Quarta-feira de Cinzas" = date,
            #"Sexta-Feira Santa" = date,
            #"Páscoa" = date,
            #"Corpus Christi" = date
        ]
    )
in
    feriadosMoveis
