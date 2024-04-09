# FILTER: Get MONDO ID by HPO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `hpo_id` HPO ID
  * default: 0000347, 0003022
  * example: 0001428, 0003745

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `hpo_id_list`
```javascript
({hpo_id}) => {
  hpo_id = hpo_id.replace(/,/g," ")
   if (hpo_id.match(/[^\s]/))  return hpo_id.split(/\s+/);
  return false;
  
//  hpo_id = hpo_id.replace(/HP:/g,"")
//  hpo_id = 'obo:' + hpo_id.replace(/[\s,]+/g," obo:")
  //hpo_id = 'hpo:' + hpo_id.replace(/[\s,]+/g," hpo:")
//  return hpo_id;
}
```

## `result`
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX sio: <http://semanticscience.org/resource/>

#SELECT COUNT( DISTINCT ?mondo_id)
SELECT *
#SELECT DISTINCT ?hpo_url ?disease STR(?mondo_id) as ?mondo_id STR(?mondo_disease_name_en) as ?mondo_disease_name_en

WHERE {
  {{#if hpo_id_list}}
    VALUES ?hpo { {{#each hpo_id_list}} obo:HP_{{this}} {{/each}} }
      {{/if}}
      ?hpo rdfs:label ?label.
      ?hpo_url rdfs:subClassOf* ?hpo .
      
     
}

```
