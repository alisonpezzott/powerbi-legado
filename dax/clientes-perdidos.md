A medida abaixo calcula a quantidade de clientes que compraram anteriormente, mas não fizeram nenhuma compra nos últimos 12 meses (ou outro período definido). 
Em outras palavras, a medida identifica os clientes que foram perdidos no período de análise especificado.

```dax
Qtd Clientes Perdidos = 

VAR __DataContexto = MAX ( dCalendario[Data] )

VAR __Gap = 12

VAR __DataInicioPeriodo = EDATE ( __DataContexto, -__Gap )

VAR __ClientesCompraramNoPeriodo = 
    CALCULATETABLE (
        VALUES ( fVendas[ClienteID] ),
        DATESBETWEEN ( dCalendario[Data], __DataInicioPeriodo, __DataContexto )
    )

VAR __CompraramAntesPeriodo =
    CALCULATETABLE (
        VALUES ( fVendas[ClienteID] ),
        dCalendario[Data] < __DataInicioPeriodo
    )

VAR __ClientesPerdidos = 
    EXCEPT ( __CompraramAntesPeriodo, __ClientesCompraramNoPeriodo )

VAR __QtdClientesPerdidos = 
    COUNTROWS ( __ClientesPerdidos )

RETURN
    __QtdClientesPerdidos 
```




### Explicação Detalhada

1. **Definição da Data de Contexto**

   ```dax
   VAR __DataContexto = MAX ( dCalendario[Data] )
   ```

   - Define a variável `__DataContexto` como a data máxima no contexto atual do calendário. Essa data representa o ponto final do período de análise.

2. **Definição do Gap**

   ```dax
   VAR __Gap = 12
   ```

   - Define a variável `__Gap` como 12, representando o número de meses que queremos olhar para trás a partir da data de contexto.

3. **Cálculo da Data de Início do Período**

   ```dax
   VAR __DataInicioPeriodo = EDATE ( __DataContexto, -__Gap )
   ```

   - Define a variável `__DataInicioPeriodo` como a data que é 12 meses antes da `__DataContexto`. A função `EDATE` é usada para subtrair meses.

4. **Identificação dos Clientes que Compraram no Período**

   ```dax
   VAR __ClientesCompraramNoPeriodo = 
       CALCULATETABLE (
           VALUES ( fVendas[ClienteID] ),
           DATESBETWEEN ( dCalendario[Data], __DataInicioPeriodo, __DataContexto )
       )
   ```

   - Define a variável `__ClientesCompraramNoPeriodo` como a tabela de IDs de clientes que compraram algo entre `__DataInicioPeriodo` e `__DataContexto`.

5. **Identificação dos Clientes que Compraram Antes do Período**

   ```dax
   VAR __CompraramAntesPeriodo =
       CALCULATETABLE (
           VALUES ( fVendas[ClienteID] ),
           dCalendario[Data] < __DataInicioPeriodo
       )
   ```

   - Define a variável `__CompraramAntesPeriodo` como a tabela de IDs de clientes que compraram algo antes de `__DataInicioPeriodo`.

6. **Determinação dos Clientes Perdidos**

   ```dax
   VAR __ClientesPerdidos = 
       EXCEPT ( __CompraramAntesPeriodo, __ClientesCompraramNoPeriodo )
   ```

   - Define a variável `__ClientesPerdidos` como a diferença entre os clientes que compraram antes do período e os que compraram durante o período. A função `EXCEPT` retorna os clientes que estavam na primeira tabela mas não na segunda, ou seja, clientes que compraram antes do período mas não durante o período.

7. **Contagem dos Clientes Perdidos**

   ```dax
   VAR __QtdClientesPerdidos = 
       COUNTROWS ( __ClientesPerdidos )
   ```

   - Define a variável `__QtdClientesPerdidos` como a contagem de linhas na tabela `__ClientesPerdidos`, ou seja, a quantidade de clientes perdidos.

8. **Retorno do Resultado**

   ```dax
   RETURN
       __QtdClientesPerdidos
   ```

   - Retorna o valor de `__QtdClientesPerdidos` como o resultado da medida.



