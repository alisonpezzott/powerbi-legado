( ano as number ) as date =>
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
    )
in
    pascoa
