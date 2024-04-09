# [PCF] FILTER: GET All ORPHA IDs - https://pubcasefinder-rdf.dbcls.jp/sparql
## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `all_orpha_id` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX oa: <http://www.w3.org/ns/oa#>

SELECT DISTINCT 
CONCAT('ORPHA:', STR(?all_orpha_id)) as ?all_orpha_id

WHERE {
  ?an oa:hasTarget ?all_orpha_uri .
  FILTER(CONTAINS(STR(?all_orpha_uri), "Orphanet_"))
  ?all_orpha_uri dcterms:identifier ?all_orpha_id .
}
```

## Output
```javascript
({all_orpha_id})=>{ 
  var pcf_orpha = all_orpha_id.results.bindings;
  var result = {}
  
  result['all_orpha_id'] = new Set();
  
  for (let i = 0; i < pcf_orpha.length; i++) {
    result['all_orpha_id'].add(pcf_orpha[i].all_orpha_id.value);
  }
  
  result['all_orpha_id'] = Array.from(result['all_orpha_id'])
  
  return result
}
```