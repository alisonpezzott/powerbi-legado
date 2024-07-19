# Formatações DateTime

Use as medidas abaixo para formatar durações no formato decimal em formato datetime (HH:MM:SS) ou no formato por extenso.

Medida [Duração Datetime HH:MM:SS]
```dax
Duração Datetime HH:MM:SS =

//Coloque aqui a sua medida com a duração na granularidade adequada
VAR __Duracao =
    [Duração em segundos]
    // ROUNDUP ( [Duração em minutos] * 60, 0 )
    // ROUNDUP ( [Duração em horas] * 3600, 0 )
    // ROUNDUP ( [Duração em dias] * 86400, 0 )

//Remove o sinal
VAR __Valor = ABS ( __Duracao )

//Extrai as horas completas
VAR __Horas =
    TRUNC ( DIVIDE ( __Valor, 3600 ) )

//Extrai os segundos restantes além das horas completas
VAR __AposHoras =
    MOD ( __Valor, 3600 )

//Extrai os minutos completos
VAR __Minutos =
    TRUNC ( DIVIDE ( __AposHoras, 60 ) )

//Segundos que não formaram minutos completos
VAR __Segundos =
    MOD ( __AposHoras, 60 )

//Se a medida for negativo adiciona o prefixo de sinal
VAR __PrefixoSinal = 
    IF ( __Duracao < 0, "-" )

//Transforma em texto
VAR __Resultado =
    IF (
        __Valor,
        __PrefixoSinal &
        FORMAT ( __Horas, "#0,0" ) & ":"
            & FORMAT ( __Minutos, "00" ) & ":"
            & FORMAT ( __Segundos, "00" )
    )

//Saída
RETURN
    __Resultado

```

Medida [Duração por extenso]

```dax
Duração por extenso = 

//Coloque aqui a sua medida com a duração na granularidade adequada
VAR __Duracao =
    [Duração em segundos]
    // ROUNDUP ( [Duração em minutos] * 60, 0 )
    // ROUNDUP ( [Duração em horas] * 3600, 0 )
    // ROUNDUP ( [Duração em dias] * 86400, 0 )

//Remove o sinal
VAR __Valor = ABS ( __Duracao )

//Extrai os dias completos
VAR __Dias = 
    TRUNC ( DIVIDE ( __Valor, 86400 ) )

//Extrai os segundos restantes além dos dias completos
VAR __AposDias = MOD ( __Valor, 86400 )

//Extrai as horas completas
VAR __Horas = 
    TRUNC ( DIVIDE ( __AposDias, 3600 ) )

//Extrai os segundos restantes além das horas completas
VAR __AposHoras = 
    MOD ( __AposDias, 3600 )

//Extrai os minutos completos
VAR __Minutos =
    TRUNC ( DIVIDE ( __AposHoras, 60 ) )

//Segundos que não formaram minutos completos
VAR __Segundos =
    MOD ( __AposHoras, 60 )

//Sufixos de texto para cada granularidade
VAR __SufixoDias = IF(__Dias = 1, " dia, ", " dias, ")
VAR __SufixoHoras = IF(__Horas = 1, " hora, ", " horas, ")
VAR __SufixoMinutos = IF(__Minutos=1, " minuto, ", " minutos, ")
VAR __SufixoSegundos = IF(__Segundos=1, " segundo", " segundos")

//Se a medida for negativo adiciona o prefixo de sinal
VAR __PrefixoSinal = 
    IF ( __Duracao < 0, "-" )

//Transforma em texto concatenado
VAR __Resultado = 
    __PrefixoSinal &
    IF ( __Dias > 0, FORMAT ( __Dias, "0" ) & __SufixoDias, BLANK ( ) ) &
    IF ( __Dias > 0 || __Horas > 0, FORMAT ( __Horas, "0" ) & __SufixoHoras, BLANK ( ) ) &
    IF ( __Dias > 0 || __Horas > 0 || __Minutos > 0, FORMAT ( __Minutos, "0" ) & __SufixoMinutos, BLANK ( ) ) &
    IF ( __Dias > 0 || __Horas > 0 || __Minutos > 0 || __Segundos > 0, FORMAT ( __Segundos, "0" ) & __SufixoSegundos, BLANK ( ) )

//Saída
RETURN
    __Resultado
```

Exemplo
| Medida Original | Valor | Medida [Duração Datetime HH:MM:SS]  | Medida [Duração por extenso] |
|---|---|---|---|
|[Duração em segundos]|24576|06:49:36|6 horas, 49 minutos, 36 segundos |
|[Duração em minutos]|738|12:18:00|12 horas, 18 minutos, 0 segundos |
|[Duração em horas]|1.3333|01:20:00|1 hora, 20 minutos, 0 segundos |
|[Duração em horas]|-5.6666|-05:40:00|-5 horas, 40 minutos, 0 segundos |
|[Duração em dias]|2.29|54:57:36| 2 dias, 6 horas, 57 minutos, 36 segundos |



