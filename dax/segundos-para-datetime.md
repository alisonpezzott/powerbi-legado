Esta medida transforma segundos para o formato hh:mm:ss

```dax

Duracao Total (hh:mm:ss texto) = 

VAR __Valor = [Duracao Total (segundos)]

VAR __Horas = TRUNC ( DIVIDE ( __Valor, 3600 ))

VAR __AposHoras = MOD ( __Valor, 3600 )

VAR __Minutos = TRUNC ( DIVIDE ( __AposHoras, 60 ) ) 

VAR __Segundos = MOD ( __AposHoras, 60 )

VAR __Resultado = 
    IF (
        __Valor,
        FORMAT ( __Horas, "00" ) & ":" &
        FORMAT ( __Minutos, "00" ) & ":" &
        FORMAT ( __Segundos, "00" )
    )

RETURN 
    __Resultado 

```


