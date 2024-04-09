# [PCF] FILTER: GET OMIM IDs by MONDO ID
## a
*  b
*  c

## Parameters

* `mondo_id`
  * default: 0018096
  * example: 0003847, 0018096, 0007477
* `rdf_portal`
  * default: https://integbio.jp/rdf/sparql  

## Endpoint

{{ rdf_portal }}

## `all_omim_id` 
```sparql
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX oa: <http://www.w3.org/ns/oa#>

SELECT DISTINCT ?all_omim_id WHERE {
  ?an oa:hasTarget ?all_omim_uri .
  FILTER(CONTAINS(STR(?all_omim_uri), "mim"))
  ?all_omim_uri dcterms:identifier ?all_omim_id .
}

```

## `mondo_omim_id` 
```sparql
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX oa: <http://www.w3.org/ns/oa#>

SELECT DISTINCT 
?omim_id
WHERE{
  mondo:MONDO_{{mondo_id}} <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_id .
  ?mondo_sub_tier rdfs:subClassOf* mondo:MONDO_{{mondo_id}} .
  ?mondo_sub_tier rdfs:label ?mondo_sub_label ;
                  <http://www.w3.org/2002/07/owl#equivalentClass> ?mim_id .
  FILTER(CONTAINS(STR(?mim_id), "OMIM_"))
  BIND (replace(str(?mim_id), 'http://purl.obolibrary.org/obo/OMIM_', '') AS ?omim_id)
}
```

## Output
```javascript
({mondo_id, all_omim_id, mondo_omim_id})=>{ 
  var pcf_omim = all_omim_id.results.bindings;
  var mondo_omim = mondo_omim_id.results.bindings;

  var result = {}
  
  result[mondo_id] = new Set();
  
  for (let i = 0; i < pcf_omim.length; i++) {
    result[mondo_id].add(pcf_omim[i].all_omim_id.value);
  }
  
  for (let i = 0; i < mondo_omim.length; i++) {
    result[mondo_id].delete(mondo_omim[i].omim_id.value);
  }
  
  result[mondo_id] = Array.from(result[mondo_id])
  
  return result
}
```