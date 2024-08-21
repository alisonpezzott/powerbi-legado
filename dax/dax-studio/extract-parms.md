This code was developed to extract de the parameters of model using DAX Studio.

```dax
DEFINE

VAR __parmsFiltered = 
	FILTER (
		INFO.CALCDEPENDENCY(),
		[REFERENCED_OBJECT_TYPE] = "M_EXPRESSION" &&
		CONTAINSSTRING ( [REFERENCED_EXPRESSION], "IsParameterQuery" )
	)
	
VAR __summarizedParms =
	SUMMARIZE (
		__parmsFiltered,
		[REFERENCED_OBJECT],
		[REFERENCED_EXPRESSION]
	 )

VAR __renamedParmsCols =
	SELECTCOLUMNS (
		__summarizedParms,
		 "ParameterName", [REFERENCED_OBJECT],
		 "ParameterExpression", [REFERENCED_EXPRESSION]
	 )
	 
EVALUATE
	__renamedParmsCols 
	
```
