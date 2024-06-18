```
let 
    funcao = ( base as number, expoente as number ) as number => 
    let 
        operacao = Number.Power ( base, expoente )
    in
        operacao,

    Documentation = type function (
        base as ( type number meta [
            Documentation.AllowedValues = {1..9},
            Documentation.FieldCaption = "base", 
            Documentation.FieldDescription = "Número que será elavado a potência"
        ]),
        expoente as ( type number meta [
            Documentation.AllowedValues = {1..9},
            Documentation.FieldCaption = "expoente", 
            Documentation.FieldDescription = "Número em que a base é multiplicada por ela mesma"
        ])
    ) as number
    meta [
        Documentation.Name = "Potência", 
        Documentation.Description = "Função eleva uma base a um expoente",
        //Documentation.LongDescription = "Entrega o valor resultante da multiplicação da base por ela mesma, pela quantidade de vezes especificado no expoente",
        Documentation.Category = "Power Query M", 
        Documentation.Version = "v0",
        Documentation.Source = "https://youtube.com/@fluentebi", 
        Documentation.Author = "Alison Pezzott", 
        Documentation.Examples = {[
            Description =  "base = 2, expoente = 3", 
            Code = "2 x 2 x 2", 
            Result = "8" 
        ]}
    ]
in 
    Value.ReplaceType ( funcao,  Documentation )
```
