``` DAX

Data Atual Quando Sem Filtros = 

VAR __IsFiltered = 
    CALCULATE(
        ISFILTERED ( dCalendario ),
        ALLSELECTED ( dCalendario[Data] )   
    ) 

VAR __Default = SELECTEDMEASURE ( )

VAR __Actual = 
    CALCULATE ( 
        SELECTEDMEASURE ( ),
        KEEPFILTERS ( dCalendario[Data] = TODAY ( ) ) 
    )

RETURN

    IF ( __IsFiltered, __Default, __Actual )

```
