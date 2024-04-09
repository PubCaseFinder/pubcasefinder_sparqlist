# [PCF] Statistics_Genetic_Diseases - https://pubcasefinder-rdf.dbcls.jp/sparql

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

SELECT COUNT(DISTINCT ?mim_id) as ?Genetic_Diseases

WHERE { 
  ?an rdf:type oa:Annotation ;
      oa:hasTarget ?mim_id ;
      oa:hasBody ?hpo_url ;
      dcterms:source [dcterms:creator ?creator] .
  FILTER(CONTAINS(STR(?mim_id), "mim"))
  FILTER(?creator NOT IN("Database Center for Life Science"))

  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
    ?hpo_url rdfs:subClassOf+ ?hpo_category .
    ?hpo_category rdfs:subClassOf obo:HP_0000118 .   
  }
}
```

## Output
```javascript
({result})=>{
  return {"Genetic Diseases":result.results.bindings[0].Genetic_Diseases.value}
}
```