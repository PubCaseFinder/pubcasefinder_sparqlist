# [PCF] Get DPA - https://pubcasefinder-rdf.dbcls.jp/sparql
## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX mim: <http://identifiers.org/mim/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>

SELECT DISTINCT
?disease_id
?hpo_id
?disease
?source

WHERE {
    ?an rdf:type oa:Annotation ;
        oa:hasTarget ?disease_url ;
        oa:hasBody ?hpo_url ;
        dcterms:source [dcterms:creator ?creator] .
  
  BIND(IF(CONTAINS(STR(?disease_url), 'ORDO'), REPLACE(STR(?disease_url), 'http://www.orpha.net/ORDO/Orphanet_', 'ORPHA:'), REPLACE(STR(?disease_url), 'http://identifiers.org/mim/', 'OMIM:')) AS ?disease_id)  
  BIND(IF(regex(?disease_url, 'http://www.orpha.net/ORDO/Orphanet_[0-9]'), 'Orphanet', 'OMIM') AS ?disease)
  BIND(IF(?creator = 'Human Phenotype Ontology Consortium', 'HPO', if(?creator = 'Database Center for Life Science', 'DBCLS', 'Orphanet')) AS ?source)
  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp> {
    ?hpo_url <http://www.geneontology.org/formats/oboInOwl#id> ?hpo_id .
  }
} order by ?disease_id ?source
limit 10
```

## Output
```javascript
({result})=>{ 
  return result.results.bindings.map(data => {
    return Object.keys(data).reduce((obj, key) => {
      obj[key] = data[key].value;
      return obj;
    }, {});
  });
}
```