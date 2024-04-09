# [PCF] FILTER: GET ORPHA IDs by MONDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0009903
  * example: 0007943, 0007318, 0010408, 0008715, 0008931, 0019880, 0016044, 0009901, 008112

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = mondo_id.replace(/MONDO:/g,"")
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
?orpha_id

WHERE {
  mondo:MONDO_{{mondo_id_list}} <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_id .
  ?mondo_sub_tier rdfs:subClassOf* mondo:MONDO_{{mondo_id_list}} ;
                  skos:exactMatch ?orpha_url .
  #               <http://www.w3.org/2002/07/owl#equivalentClass> ?orpha_url .
  FILTER(CONTAINS(STR(?orpha_url), "Orphanet_"))  
  BIND (replace(str(?orpha_url), 'http://www.orpha.net/ORDO/Orphanet_', '') AS ?orpha_id)
}
```

## Output
```javascript
({mondo_id_list, result})=>{ 
  var list = []
  var dic = {}
  var rows = result.results.bindings;

  for (let i = 0; i < rows.length; i++) {
    list.push('ORPHA:' + rows[i].orpha_id.value);
  }

  if(rows){
    dic['MONDO:' + mondo_id_list] = list;
  }
  
  return dic
}