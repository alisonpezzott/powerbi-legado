Os cálculos abaixo são os cálculos mais comuns utilizados para indicadores de Headcount.  
Para que as medidas abaixo funcionem exatamente iguais, o modelo deve possuir uma ao menos uma tabela  
dFuncionarios contendo colunas de DataAdmissao, DataDesligamento e uma tabela dCalendario com  
relacionamento inativo com estas duas colunas.  

```dax
Ativos = 

VAR __DataContexto = MAX ( dCalendario[Data] )

VAR __Resultado = 
  COUNTROWS (
    FILTER (
      dFuncionarios,
      dFuncionarios[DataAdmissao] <= __DataContexto
      &&  (
          dFuncionarios[DataDesligamento] > __DataContexto
          || ISBLANK ( dFuncionarios[DataDesligamento] )
      )
    )
  )

RETURN __Resultado
```

```dax
Admitidos = 
  COUNTROWS (
    CALCULATETABLE ( 
      dFuncionarios,
      USERELATIONSHIP (
        dCalendario[Data],
        dFuncionarios[DataAdmissao]
      )
    )
  )
```

```dax
Desligados = 
  COUNTROWS (
    CALCULATETABLE ( 
      dFuncionarios,
      USERELATIONSHIP (
        dCalendario[Data],
        dFuncionarios[DataDesligamento]
      ),
      NOT ISBLANK ( dFuncionarios[DataDesligamento] ) 
    )
  )
```
  
```dax
Saldo Operacional = [Admitidos] - [Desligados]
```

```dax
Ativos Anterior = 

VAR __DataContexto = MIN ( dCalendario[Data] )

VAR __Resultado = 
  CALCULATE ( 
    [Ativos],
    dCalendario[Data] < __DataContexto
  )

RETURN __Resultado
```
  
```dax
% Crescimento = 

VAR __Atual = [Ativos]

VAR __Anterior = [Ativos Anterior]

VAR __Resultado = 
  DIVIDE ( 
    __Atual - __Anterior,
    __Anterior
  )

RETURN __Resultado 
```
