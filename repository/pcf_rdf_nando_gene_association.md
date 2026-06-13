## Endpoint
https://nanbyodata.jp/sparql

## `result` 
```sparql
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT DISTINCT
(STRAFTER(STR(?nando), "NANDO_") AS ?nando_id)
?gene_id
WHERE {
  ?nando sio:SIO_000352 ?blank.
  FILTER(STRSTARTS(STR(?nando), "http://nanbyodata.jp/ontology/NANDO_12"))
  ?blank rdfs:seeAlso ?gene.
  ?gene dcterms:identifier ?gene_id .
}
ORDER BY ?nando

```

## Output
```javascript
({text({result}){ // tsv
    var vars = result.head.vars;
    var list = result.results.bindings;
    var text = vars.join("\t") + "\n";   // 헤더 출력
    for(var i = 0; i < list.length; i++){
      var values = [];
      for(var j = 0; j < vars.length; j++){
        var val = ""; 
        if(list[i][vars[j]]) val = list[i][vars[j]].value;
        if(val.match(/^\".+\"$/)) val = val.match(/^\"(.+)\"$/)[1];
        values.push(val);
      }
      text += values.join("\t") + "\n";
    }
    return text;
  }
})
```