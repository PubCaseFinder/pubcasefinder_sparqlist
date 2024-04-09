# [PCF] Get HPO data by HPO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `hpo_id` HPO ID
  * default: HP:0000347, 0003022, HP:0009381, 0000204, 0000625
  * example: 0410219, 0031815, 0040184

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `hpo_id_list`
```javascript
({hpo_id}) => {
  hpo_id = hpo_id.replace(/HP:/g,"")
  hpo_id = 'obo:' + hpo_id.replace(/[\s,]+/g," obo:")
  return hpo_id;
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX mim: <http://identifiers.org/mim/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/HP_>

SELECT DISTINCT
str(?name_en) as ?name_en
str(?name_ja) as ?name_ja
?hp
WHERE { 
  VALUES ?hp_id { {{hpo_id_list}} }

  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
    ?hp_id rdfs:label ?name_en .
  }

  optional { ?hp_id rdfs:label ?name_ja . FILTER (lang(?name_ja) = "ja") }
  BIND (replace(str(?hp_id), 'http://purl.obolibrary.org/obo/HP_', '') AS ?hp )
}
```


## Output
```javascript
({result})=>{ 
  var dic = {}
  var rows = result.results.bindings;
  
  for (let i = 0; i < rows.length; i++) {
    dic['HP:' + rows[i].hp.value] = {};

    if (rows[i].name_en) { 
      dic['HP:' + rows[i].hp.value].name_en = rows[i].name_en.value
    }
    if (rows[i].name_ja) { 
      dic['HP:' + rows[i].hp.value].name_ja = rows[i].name_ja.value
    }
  }
  
  return dic
}
```