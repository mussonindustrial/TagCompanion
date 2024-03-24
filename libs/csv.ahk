#Include "strings.ahk"

; Parse a CSV string into an array.
CSVParse(str) {
    array := []
    loop parse, str, "CSV"
        array.Push(A_LoopField)
    return array
}

; Import a CSV file into an array of maps, with keys corresponding to values in the header row.
CSVToArray(filePath) {
    data := StrSplit(FileRead(filePath), "`n", "`r")
    csvArray := map()
    header := CSVParse(data.removeat(1))
    for rowIndex, rowData in data {
        if (rowData != "") {
            csvArray[rowIndex] := map()
            for k,v in CSVParse(rowData) {
                csvArray[rowIndex][header[k]] := v
            }
        }
    }
    return csvArray
}