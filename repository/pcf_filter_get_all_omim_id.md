# [PCF] FILTER: GET All OMIM IDs - https://pubcasefinder-rdf.dbcls.jp/sparql
## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `all_omim_id` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX oa: <http://www.w3.org/ns/oa#>

SELECT DISTINCT 
CONCAT('OMIM:', STR(?all_omim_id)) as ?all_omim_id

WHERE {
  ?an oa:hasTarget ?all_omim_uri .
  FILTER(CONTAINS(STR(?all_omim_uri), "mim"))
  ?all_omim_uri dcterms:identifier ?all_omim_id .
}
```

## Output
```javascript
({all_omim_id})=>{ 
  var pcf_omim = all_omim_id.results.bindings;
  var result = {}
  
  result['all_omim_id'] = new Set();
  
  for (let i = 0; i < pcf_omim.length; i++) {
    result['all_omim_id'].add(pcf_omim[i].all_omim_id.value);
  }
  
  result['all_omim_id'] = Array.from(result['all_omim_id'])
  
  return result
}
```