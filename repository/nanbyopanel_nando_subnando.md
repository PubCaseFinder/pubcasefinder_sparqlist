# [PCF] Get NANDO SUB ID data by NANDO ID - https://dev-pubcasefinder.dbcls.jp/sparql
## Parameters
* `nando_id` NANDO ID
  * default: 1100001 1100002
  * example: 1200404, 1201073, 1200010, 120011

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql

## `nando_id_list`
```javascript
({nando_id}) => {
  nando_id = nando_id.replace(/NANDO:/g,"")
  nando_id = 'NANDO:' + nando_id.replace(/[\s,]+/g," NANDO:")
  return nando_id;
}
```

## `result` 
```sparql
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX NANDO: <http://nanbyodata.jp/ontology/NANDO_>

SELECT DISTINCT ?nando_id
WHERE 
{
  VALUES ?root_nando { {{nando_id_list}}  }
  ?nando rdfs:subClassOf+ ?root_nando ;
         dcterms:identifier ?nando_id .
}
ORDER BY ?nando_id
```
## `return`
```javascript
({text({result}){ // tsv
    var vars = result.head.vars;
    var list = result.results.bindings;
    var text = ""
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