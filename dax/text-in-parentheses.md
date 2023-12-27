# How to extract a slice of a string between parentheses regardless of its position with the DAX on Power BI?

## 1. First create a table called 'DataTable' with the following code

```dax
DataTable = 
SELECTCOLUMNS (
    {
        "Example 1 - (TXT-0001)",
        "(TXT-0002) - Example 2",
        "Example (TXT-0003) - 3"
    },
     "Text",
    [Value]
) 
```

Output
| Text |
| --- |
|Example 1 - (TXT-0001)|
|(TXT-0002) - Example 2|
|Example (TXT-0003) - 3|

<br></br>

## 2. Add a calculated column with the following code:

```dax
ExtractedText =

VAR __SourceText = DataTable[Text]

RETURN __SourceText
```

Output
| Text | ExtractedText |
| --- | --- |
|Example 1 - (TXT-0001)|Example 1 - (TXT-0001)|
|(TXT-0002) - Example 2|(TXT-0002) - Example 2|
|Example (TXT-0003) - 3|Example (TXT-0003) - 3|

The new added column just copied the source column, ok.

<br></br>

## 3. Modify the DAX to extract the start position of the desired text.
```dax
ExtractedText =

VAR __SourceText = DataTable[Text]

VAR __StartPosition = SEARCH ( "(", __SourceText, 1, BLANK ( ) ) + 1

RETURN __StartPosition
```
Output
| Text | ExtractedText |
| --- | --- |
|Example 1 - (TXT-0001)|14|
|(TXT-0002) - Example 2|2|
|Example (TXT-0003) - 3|10|

The variable __StartPosition finds the oppening parentheses position and plus 1, however, it's the start of our desired extracted text.

<br></br>

## 4. Modify the DAX to extract the end position of the desired text.

```dax
ExtractedText =

VAR __SourceText = DataTable[Text]

VAR __StartPosition = SEARCH ( "(", __SourceText, 1, BLANK ( ) ) + 1

VAR __EndPosition = SEARCH ( ")", __SourceText, 1, BLANK ( ) )

RETURN __EndPosition
```
Output
| Text | ExtractedText |
| --- | --- |
|Example 1 - (TXT-0001)|22|
|(TXT-0002) - Example 2|10|
|Example (TXT-0003) - 3|18|

The variable __EndPosition finds the closing patentheses position.

<br></br>

## 5. Modify the DAX to extract the length between start and end positions
```dax
ExtractedText =

VAR __SourceText = DataTable[Text]

VAR __StartPosition = SEARCH ( "(", __SourceText, 1, BLANK ( ) ) + 1

VAR __EndPosition = SEARCH ( ")", __SourceText, 1, BLANK ( ) )

VAR __Lenght = __EndPosition - __StartPosition

RETURN __Lenght
```
Output
| Text | ExtractedText |
| --- | --- |
|Example 1 - (TXT-0001)|8|
|(TXT-0002) - Example 2|8|
|Example (TXT-0003) - 3|8|

The length in this case is the same.

<br></br>

## 6. Finally, modify the DAX to brings the desired extracted text.
```dax
ExtractedText =

VAR __SourceText = DataTable[Text]

VAR __StartPosition = SEARCH ( "(", __SourceText, 1, BLANK ( ) ) + 1

VAR __EndPosition = SEARCH ( ")", __SourceText, 1, BLANK ( ) )

VAR __Lenght = __EndPosition - __StartPosition

VAR __Result = MID ( __SourceText, __StartPosition, __Lenght )

RETURN __Result
```

Output
| Text | ExtractedText |
| --- | --- |
|Example 1 - (TXT-0001)|TXT-0001|
|(TXT-0002) - Example 2|TXT-0002|
|Example (TXT-0003) - 3|TXT-0003|

The MID function extracts a part of a string specified by a start position and the length.

<br></br>

## 7. Also its's possible use this syntax on a measure with a small correction, adding an aggregation funcion to the source.

```dax
Extracted Text =

VAR __SourceText = SELECTEDVALUE ( DataTable[Text] )

VAR __StartPosition = SEARCH ( "(", __SourceText, 1, BLANK ( ) ) + 1

VAR __EndPosition = SEARCH ( ")", __SourceText, 1, BLANK ( ) )

VAR __Lenght = __EndPosition - __StartPosition

VAR __Result = MID ( __SourceText, __StartPosition, __Lenght )

RETURN __Result
```

To see the result it's necessary add a table visual on the screen. Add the column DataTable[Text] and the measure  [Extracted Text] on the field values of the visual.

![image](https://github.com/alisonpezzott/powerbi/assets/58135934/8dd6506d-e73c-46d4-bc00-fbadf1151594)

