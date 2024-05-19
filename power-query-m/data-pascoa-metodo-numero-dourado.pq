( ano as number ) as date =>
let
    tabelaRef = Table.FromColumns (
        {
            { 1..19 },
            { 4, 4, 3, 4, 3, 4, 4, 3, 4, 4, 3, 4, 4, 3, 4, 3, 4, 4, 3 },
            { 14, 3, 23, 11, 31, 18, 8, 28, 16, 5, 25, 13, 2, 22, 10, 30, 17, 7, 27 }
        },
        { "NumeroDourado", "Mes", "Dia" }
    ),
    numeroDourado = Number.Mod ( ano, 19 ) + 1,
    selecao = Table.SelectRows ( tabelaRef, each [NumeroDourado] = numeroDourado ){0},
    dataSelecionada = #date ( ano, selecao[Mes], selecao[Dia] ),
    pascoa = if Date.DayOfWeek ( dataSelecionada, Day.Monday ) = 6
        then Date.AddDays ( dataSelecionada, 7 )
        else Date.EndOfWeek ( dataSelecionada, Day.Monday )
in
    pascoa
