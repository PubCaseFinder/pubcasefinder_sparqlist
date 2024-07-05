# [PCF] FILTER: GET OMIM IDs by MONDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0018096
  * example: 0003847, 0018096, 0007477

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = mondo_id.replace(/MONDO:/g,"")
  mondo_id = 'mondo:MONDO_' + mondo_id.replace(/[\s,]+/g," mondo:MONDO_")
  return mondo_id;
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT DISTINCT 
?omim_id

WHERE {
  VALUES ?mondo_list { {{mondo_id_list}} }
  
  #mondo:MONDO_{{mondo_id_list}} <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_id .
  ?mondo_list <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_id .
  
  #?mondo_sub_tier rdfs:subClassOf* mondo:MONDO_{{mondo_id_list}} ;
  ?mondo_sub_tier rdfs:subClassOf* ?mondo_list ;
                  skos:exactMatch ?mim_uri .
  FILTER(CONTAINS(STR(?mim_uri), "mim"))
  BIND (replace(str(?mim_uri), 'http://identifiers.org/omim/', '') AS ?omim_id)
  
  #mondo 갱신으로 임시 소스
  #FILTER(CONTAINS(STR(?mim_uri), "entry"))
  #BIND (replace(str(?mim_uri), 'https://omim.org/entry/', '') AS ?omim_id)
  
  #mondo 갱신으로 인한 잠시 주석화
  #FILTER(CONTAINS(STR(?mim_id), "OMIM_"))
  #BIND (replace(str(?mim_id), 'http://purl.obolibrary.org/obo/OMIM_', '') AS ?omim_id)
}
```

## Output
```javascript
({mondo_id_list, result})=>{ 
  var list = []
  var dic = {}
  var rows = result.results.bindings;

  for (let i = 0; i < rows.length; i++) {
    list.push('OMIM:' + rows[i].omim_id.value);
  }

  if(rows){
    //dic['MONDO:' + mondo_id_list] = list;
    dic[mondo_id_list.replace(/mondo:MONDO_/gi,'MONDO:').replace(/ /gi,'|')] = list;
  }
  
  return dic
}