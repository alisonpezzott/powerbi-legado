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
    feriadosMoveis =  Table.FromRecords (
        {
            [ Data = Date.AddDays ( pascoa, -48 ), Feriado = "Segunda-feira de Carnaval" ],
            [ Data = Date.AddDays ( pascoa, -47 ), Feriado = "Terça-feira de Carnaval"   ],
            [ Data = Date.AddDays ( pascoa, -46 ), Feriado = "Quarta-feira de Cinzas"    ],
            [ Data = Date.AddDays ( pascoa, -2  ), Feriado = "Sexta-Feira Santa"         ],
            [ Data = pascoa                      , Feriado = "Páscoa"                    ],
            [ Data = Date.AddDays ( pascoa, 60  ), Feriado = "Corpus Christi"            ]
        },
        type table [
            Data = date,
            Feriado = text
        ]
    )
in
    feriadosMoveis
