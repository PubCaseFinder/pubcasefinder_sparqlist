# [PCF] FILTER: GET OMIM ID by NANDO ID - https://dev-pubcasefinder.dbcls.jp/sparql
## Parameters
* `nando_id` NANDO ID
  * default: 1200295 
  * examples: 1000001, 2000001, 1200003
  
## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql

## `nando_id_list`
```javascript
({nando_id}) => {
  nando_id = nando_id.replace(/NANDO:/g,"")
  nando_id = 'nando:' + nando_id.replace(/[\s,]+/g," nando:")
  return nando_id;
}
```

## `result`
```sparql
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT DISTINCT ?omim_id
WHERE {
  VALUES ?nando_id { {{nando_id_list}} }
  ?nando_id a owl:Class .
  ?nando_sub_tier rdfs:subClassOf* ?nando_id ;
                  skos:closeMatch ?mondo .
  ?mondo skos:exactMatch ?mim_uri .
  FILTER(CONTAINS(STR(?mim_uri), "mim"))
  BIND (replace(str(?mim_uri), 'http://identifiers.org/omim/', '') AS ?omim_id)
}
```

## Output
```javascript
({nando_id_list, result})=>{ 
  var list = []
  var dic = {}
  var rows = result.results.bindings;

  for (let i = 0; i < rows.length; i++) {
    list.push('OMIM:' + rows[i].omim_id.value);
  }

  if(rows){
    //dic['NANDO:' + nando_id_list] = list;
    dic[nando_id_list.replace(/nando:/gi,'NANDO:').replace(/ /gi,'|')] = list;
  }
  
  return dic
}