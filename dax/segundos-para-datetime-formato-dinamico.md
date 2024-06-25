Esta sintaxe deve incluída no campo de formato dinâmico de uma medida que contém o valor em segundos.

```dax

VAR __Valor = SELECTEDMEASURE ( )

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
    """" & __Resultado & """" 

```
