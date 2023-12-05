# Window functions DAX

## INDEX

> Retorna a linha da tabela determinada pela sua posição **absoluta** ordenada por um critério especificado

```dax
Top dia da semana por faturamento = 
    INDEX (
        1,
        ALLSELECTED ( dCalendario[Nome do Dia da Semana] ),
        ORDERBY ( [Faturamento], DESC )

    )
)
```

```dax
Faturamento do top dia da semana = 
    CALCULATE ( 
        [Faturamento],
        KEEPFILTERS (
            INDEX (
                1,
                ALLSELECTED ( dCalendario[Nome do Dia da Semana] ),
                ORDERBY ( [Faturamento], DESC )
            )
        )
    )
```

```dax
Top dia da semana e faturamento = 
VAR _Index = 
    INDEX (
        1,
        SUMMARIZE (
            ALLSELECTED ( dCalendario[Nome do Dia da Semana] ),
            dCalendario[Nome do Dia da Semana],
            "@Faturamento", [Faturamento]
        ),
        ORDERBY ( [Faturamento], DESC )
    )
VAR _Result = 
    MAXX (
        _Index,
        [Nome do Dia da Semana] & UNICHAR ( 10 ) &
        FORMAT ( [@Faturamento], "R$ #,#0.00" )
    )
RETURN
    _Result
```

```dax
Faturamento do pior dia da semana = 
    CALCULATE ( 
        [Faturamento],
        KEEPFILTERS (
            INDEX (
                -1,
                FILTER (
                    ALLSELECTED ( dCalendario[Nome do Dia da Semana] ),
                    [Faturamento]
                ),
                ORDERBY ( [Faturamento], DESC )
            )
        )
    )
```

## OFFSET

> Retorna a linha da tabela determinada pela sua posição **relativa** ordenada por um critério especificado

```dax
Delta faturamento superior = 
VAR _Offset = 
    OFFSET (
        -1,
        ALLSELECTED ( dVendedores[Vendedor] ),
        ORDERBY ( [Faturamento], DESC )
    )
VAR _Superior = 
    CALCULATE (
        [Faturamento],
        _Offset
    )
VAR _Primeiro = 
    INDEX (
        1,
        ALLSELECTED ( dVendedores[Vendedor] ),
        ORDERBY ( [Faturamento], DESC )
    )
VAR _Result = 
    IF ( 
        ISINSCOPE ( dVendedores[Vendedor] ) && 
        SELECTEDVALUE ( dVendedores[Vendedor] ) <> _Primeiro,
        _Superior - [Faturamento]
    )
RETURN
    _Result
```

```dax
% Delta Superior = DIVIDE ( [Delta faturamento superior], [Faturamento] )
```

## WINDOW

### Case 1 - Top Estados

> Retorna o intervalo (janela) das linhas absolutas ou relativas de uma tabela determinada pelo critério de ordenação especificado.

```dax
Top 3 estados do país = 
VAR _Window = 
    WINDOW (
        1, ABS,
        3, ABS,
        ALLSELECTED ( dMunicipios[Estado] ),
        ORDERBY ( [Faturamento], DESC )
    )
VAR _Result = 
    CONCATENATEX (
        _Window,
        [Estado],
        ", ",
        [Faturamento], DESC
    )
RETURN
    _Result
```

```dax
Faturamento top 3 estados do país = 
VAR _Window = 
    WINDOW (
        1, ABS,
        3, ABS,
        ALLSELECTED ( dMunicipios[Estado], dMunicipios[Regiao] ),
        ORDERBY ( [Faturamento], DESC )
    )
VAR _Result = 
    CALCULATE (
        [Faturamento],
        KEEPFILTERS ( _Window )
    )
RETURN
    _Result
```

```dax
Faturamento top 3 estados de cada região = 
VAR _Window = 
    WINDOW (
        1, ABS,
        3, ABS,
        ALLSELECTED ( dMunicipios[Estado], dMunicipios[Regiao] ),
        ORDERBY ( [Faturamento], DESC ),
        PARTITIONBY ( dMunicipios[Regiao] )
    )
VAR _Result = 
    CALCULATE (
        [Faturamento],
        KEEPFILTERS ( _Window )
    )
RETURN
    _Result
```

### Case 2 - Acumulado e Pareto

```dax
Faturamento Acumulado = 
VAR _Cor = 
CALCULATE (
    [Faturamento],
    WINDOW (
        1, ABS,
        0, REL,
        ALLSELECTED ( dProdutos[Cor] ),
        ORDERBY ( [Faturamento], DESC )
    )
)
VAR _CorParticao = 
CALCULATE (
    [Faturamento],
    WINDOW (
        1, ABS,
        0, REL,
        SUMMARIZE (
            ALLSELECTED ( fVendas ),
            dMunicipios[Regiao], 
            dVendedores[Vendedor], 
            dProdutos[Cor] 
        ),
        ORDERBY ( [Faturamento], DESC ),
        PARTITIONBY ( dVendedores[Vendedor], dMunicipios[Regiao] )
    )
)
VAR _Vendedor = 
CALCULATE (
    [Faturamento],
    WINDOW (
        1, ABS,
        0, REL,
        ALLSELECTED ( dVendedores[Vendedor] ),
        ORDERBY ( [Faturamento], DESC )
    )
)
VAR _VendedorParticao = 
CALCULATE (
    [Faturamento],
    WINDOW (
        1, ABS,
        0, REL,
        SUMMARIZE (
            ALLSELECTED ( fVendas ),
            dMunicipios[Regiao], 
            dVendedores[Vendedor]
        ),
        ORDERBY ( [Faturamento], DESC ),
        PARTITIONBY ( dMunicipios[Regiao] )
    )
)
VAR _Regiao = 
CALCULATE (
    [Faturamento],
    WINDOW (
        1, ABS,
        0, REL,
        FILTER (
            ALLSELECTED ( dMunicipios[Regiao] ),
            [Faturamento]
        ),
        ORDERBY ( [Faturamento], DESC )
    )
)
VAR _Acumulado = 
    SWITCH (
        TRUE ( ),
        ISINSCOPE ( dProdutos[Cor] ) 
            && HASONEVALUE ( dVendedores[Vendedor] ), _CorParticao,
        ISINSCOPE ( dProdutos[Cor] ), _Cor,
        ISINSCOPE ( dVendedores[Vendedor] )
            && HASONEVALUE ( dMunicipios[Regiao] ), _VendedorParticao,
        ISINSCOPE ( dVendedores[Vendedor] ), _Vendedor,
        ISINSCOPE ( dMunicipios[Regiao] ), _Regiao
    )
RETURN
    _Acumulado
```

```dax
Faturamento Pareto = 
VAR _Cor = 
CALCULATE (
    [Faturamento],
    WINDOW (
        1, ABS,
        -1, ABS,
        ALLSELECTED ( dProdutos[Cor] ),
        ORDERBY ( [Faturamento], DESC )
    )
)
VAR _CorParticao = 
CALCULATE (
    [Faturamento],
    WINDOW (
        1, ABS,
        -1, ABS,
        SUMMARIZE (
            ALLSELECTED ( fVendas ),
            dMunicipios[Regiao], 
            dVendedores[Vendedor], 
            dProdutos[Cor] 
        ),
        ORDERBY ( [Faturamento], DESC ),
        PARTITIONBY ( dVendedores[Vendedor], dMunicipios[Regiao] )
    )
)
VAR _Vendedor = 
CALCULATE (
    [Faturamento],
    WINDOW (
        1, ABS,
        -1, ABS,
        ALLSELECTED ( dVendedores[Vendedor] ),
        ORDERBY ( [Faturamento], DESC )
    )
)
VAR _VendedorParticao = 
CALCULATE (
    [Faturamento],
    WINDOW (
        1, ABS,
        -1, ABS,
        SUMMARIZE (
            ALLSELECTED ( fVendas ),
            dMunicipios[Regiao], 
            dVendedores[Vendedor]
        ),
        ORDERBY ( [Faturamento], DESC ),
        PARTITIONBY ( dMunicipios[Regiao] )
    )
)
VAR _Regiao = 
CALCULATE (
    [Faturamento],
    WINDOW (
        1, ABS,
        -1, ABS,
        FILTER (
            ALLSELECTED ( dMunicipios[Regiao] ),
            [Faturamento]
        ),
        ORDERBY ( [Faturamento], DESC )
    )
)
VAR _Acumulado = 
    SWITCH (
        TRUE ( ),
        ISINSCOPE ( dProdutos[Cor] ) 
            && HASONEVALUE ( dVendedores[Vendedor] ), _CorParticao,
        ISINSCOPE ( dProdutos[Cor] ), _Cor,
        ISINSCOPE ( dVendedores[Vendedor] )
            && HASONEVALUE ( dMunicipios[Regiao] ), _VendedorParticao,
        ISINSCOPE ( dVendedores[Vendedor] ), _Vendedor,
        ISINSCOPE ( dMunicipios[Regiao] ), _Regiao
    )
VAR _Result = DIVIDE ( [Faturamento Acumulado], _Acumulado )
RETURN
    _Result
```

### Case 3 - Acumulado e pareto com parâmetros de campos e grupos de cálculos + WINDOW e RANK

```dax
//criando o parâmetro Campos
Campos = {
    ( "Faturamento", NAMEOF('Medidas'[Faturamento]), 0),
    ( "Pedidos"    , NAMEOF('Medidas'[Pedidos])    , 1),
    ( "Qtd Vendida", NAMEOF('Medidas'[Qtd Vendida]), 2)
}
```

```dax
//cria-se o grupo de cálculo 'GC - Pareto' com o primeiro item
Medida Selecionada = SELECTEDMEASURE ( )
```

```dax
//item de cálculo
GC Acumulado = 
VAR _Cor = 
CALCULATE (
    SELECTEDMEASURE ( ),
    WINDOW (
        1, ABS,
        0, REL,
        ALLSELECTED ( dProdutos[Cor] ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC )
    )
)
VAR _CorParticao = 
CALCULATE (
    SELECTEDMEASURE ( ),
    WINDOW (
        1, ABS,
        0, REL,
        SUMMARIZE (
            ALLSELECTED ( fVendas ),
            dMunicipios[Regiao], 
            dVendedores[Vendedor], 
            dProdutos[Cor] 
        ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC ),
        PARTITIONBY ( dVendedores[Vendedor], dMunicipios[Regiao] )
    )
)
VAR _Vendedor = 
CALCULATE (
    SELECTEDMEASURE ( ),
    WINDOW (
        1, ABS,
        0, REL,
        ALLSELECTED ( dVendedores[Vendedor] ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC )
    )
)
VAR _VendedorParticao = 
CALCULATE (
    SELECTEDMEASURE ( ),
    WINDOW (
        1, ABS,
        0, REL,
        SUMMARIZE (
            ALLSELECTED ( fVendas ),
            dMunicipios[Regiao], 
            dVendedores[Vendedor]
        ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC ),
        PARTITIONBY ( dMunicipios[Regiao] )
    )
)
VAR _Regiao = 
CALCULATE (
    SELECTEDMEASURE ( ),
    WINDOW (
        1, ABS,
        0, REL,
        FILTER (
            ALLSELECTED ( dMunicipios[Regiao] ),
            SELECTEDMEASURE ( )
        ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC )
    )
)
VAR _Acumulado = 
    SWITCH (
        TRUE ( ),
        ISINSCOPE ( dProdutos[Cor] ) 
            && HASONEVALUE ( dVendedores[Vendedor] ), _CorParticao,
        ISINSCOPE ( dProdutos[Cor] ), _Cor,
        ISINSCOPE ( dVendedores[Vendedor] )
            && HASONEVALUE ( dMunicipios[Regiao] ), _VendedorParticao,
        ISINSCOPE ( dVendedores[Vendedor] ), _Vendedor,
        ISINSCOPE ( dMunicipios[Regiao] ), _Regiao
    )
RETURN
    _Acumulado
```

```dax
//item de cálculo
GC Pareto = 
VAR _Cor = 
CALCULATE (
    SELECTEDMEASURE ( ),
    WINDOW (
        1, ABS,
        -1, ABS,
        ALLSELECTED ( dProdutos[Cor] ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC )
    )
)
VAR _CorParticao = 
CALCULATE (
    SELECTEDMEASURE ( ),
    WINDOW (
        1, ABS,
        -1, ABS,
        SUMMARIZE (
            ALLSELECTED ( fVendas ),
            dMunicipios[Regiao], 
            dVendedores[Vendedor], 
            dProdutos[Cor] 
        ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC ),
        PARTITIONBY ( dVendedores[Vendedor], dMunicipios[Regiao] )
    )
)
VAR _Vendedor = 
CALCULATE (
    SELECTEDMEASURE ( ),
    WINDOW (
        1, ABS,
        -1, ABS,
        ALLSELECTED ( dVendedores[Vendedor] ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC )
    )
)
VAR _VendedorParticao = 
CALCULATE (
    SELECTEDMEASURE ( ),
    WINDOW (
        1, ABS,
        -1, ABS,
        SUMMARIZE (
            ALLSELECTED ( fVendas ),
            dMunicipios[Regiao], 
            dVendedores[Vendedor]
        ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC ),
        PARTITIONBY ( dMunicipios[Regiao] )
    )
)
VAR _Regiao = 
CALCULATE (
    SELECTEDMEASURE ( ),
    WINDOW (
        1, ABS,
        -1, ABS,
        FILTER (
            ALLSELECTED ( dMunicipios[Regiao] ),
            SELECTEDMEASURE ( )
        ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC )
    )
)
VAR _Acumulado = 
    SWITCH (
        TRUE ( ),
        ISINSCOPE ( dProdutos[Cor] ) 
            && HASONEVALUE ( dVendedores[Vendedor] ), _CorParticao,
        ISINSCOPE ( dProdutos[Cor] ), _Cor,
        ISINSCOPE ( dVendedores[Vendedor] )
            && HASONEVALUE ( dMunicipios[Regiao] ), _VendedorParticao,
        ISINSCOPE ( dVendedores[Vendedor] ), _Vendedor,
        ISINSCOPE ( dMunicipios[Regiao] ), _Regiao
    )
VAR _GcAcumulado = 
    CALCULATE (
        SELECTEDMEASURE ( ),
        'GC Pareto'[GC Pareto] = "GC Acumulado"
    )
VAR _Result = DIVIDE ( _GcAcumulado, _Acumulado )
RETURN
    _Result
```

```dax
//item de cálculo
GC Rank = 
VAR _Cor = 
    RANK (
        DENSE,
        ALLSELECTED ( dProdutos[Cor] ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC )
    )
VAR _CorParticao = 
    RANK (
        DENSE,
        SUMMARIZE (
            ALLSELECTED ( fVendas ),
            dMunicipios[Regiao], 
            dVendedores[Vendedor], 
            dProdutos[Cor] 
        ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC ),
        PARTITIONBY ( dVendedores[Vendedor], dMunicipios[Regiao] )
    )
VAR _Vendedor = 
    RANK (
        DENSE,
            ALLSELECTED ( dVendedores[Vendedor] ),
            ORDERBY ( SELECTEDMEASURE ( ), DESC )
    )
VAR _VendedorParticao = 
    RANK (
        DENSE,
        SUMMARIZE (
            ALLSELECTED ( fVendas ),
            dMunicipios[Regiao], 
            dVendedores[Vendedor]
        ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC ),
        PARTITIONBY ( dMunicipios[Regiao] )
    )
VAR _Regiao = 
    RANK (
        DENSE,
        FILTER (
            ALLSELECTED ( dMunicipios[Regiao] ),
            SELECTEDMEASURE ( )
        ),
        ORDERBY ( SELECTEDMEASURE ( ), DESC )
    )
VAR _Acumulado = 
    SWITCH (
        TRUE ( ),
        ISINSCOPE ( dProdutos[Cor] ) 
            && HASONEVALUE ( dVendedores[Vendedor] ), _CorParticao,
        ISINSCOPE ( dProdutos[Cor] ), _Cor,
        ISINSCOPE ( dVendedores[Vendedor] )
            && HASONEVALUE ( dMunicipios[Regiao] ), _VendedorParticao,
        ISINSCOPE ( dVendedores[Vendedor] ), _Vendedor,
        ISINSCOPE ( dMunicipios[Regiao] ), _Regiao
    )
RETURN
    _Acumulado
```

```dax
//medida
GC Acumulado = 
CALCULATE (
    SWITCH (
        SELECTEDVALUE ( Campos[Campos Pedido] ), 
        0, [Faturamento],
        1, [Pedidos],
        2, [Qtd Vendida]
    ),
    'GC Pareto'[GC Pareto] = "GC Acumulado"
) 


//formato dinâmico
VAR _Valor =  SELECTEDMEASURE ( )
VAR _Formato = 
    CALCULATE (
        SWITCH (
            SELECTEDVALUE ( Campos[Campos Pedido] ), 
            0, "R$ #,#0.00",
            1, "#,#0",
            2, "#,#0"
        )
    )
RETURN
    """" & FORMAT ( _Valor, _Formato ) & """"
```

```dax
//medida
GC Pareto = 
CALCULATE (
    SWITCH (
        SELECTEDVALUE ( Campos[Campos Pedido] ), 
        0, [Faturamento],
        1, [Pedidos],
        2, [Qtd Vendida]
    ),
    'GC Pareto'[GC Pareto] = "GC Pareto"
)
```

```dax
//medida
GC Rank = 
CALCULATE (
    SWITCH (
        SELECTEDVALUE ( Campos[Campos Pedido] ), 
        0, [Faturamento],
        1, [Pedidos],
        2, [Qtd Vendida]
    ),
    'GC Pareto'[GC Pareto] = "GC Rank"
)
```
