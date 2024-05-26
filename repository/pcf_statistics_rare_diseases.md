# [PCF] Statistics_Rare_Diseases - https://pubcasefinder-rdf.dbcls.jp/sparql

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX hoom: <http://www.semanticweb.org/ontology/HOOM#>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ordo: <http://www.orpha.net/ORDO/>

SELECT COUNT(DISTINCT ?orpha_id) as ?Rare_Diseases
#SELECT COUNT(?orpha_id) as ?Rare_Diseases

WHERE { 
  ?an rdf:type oa:Annotation ;
      oa:hasTarget ?orpha_id ;
      oa:hasBody ?hpo_url ;
      dcterms:source [dcterms:creator ?creator] .
  FILTER(CONTAINS(STR(?orpha_id), "ORDO"))
  FILTER(?creator NOT IN("Database Center for Life Science"))
  
  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
    ?hpo_url rdfs:subClassOf+ ?hpo_category .
    ?hpo_category rdfs:subClassOf obo:HP_0000118 .   
    #?hpo_category rdfs:subClassOf obo:HP_0025354 .   
  }
  
}
```

## Output
```javascript
({result})=>{
  return {"Rare Diseases":result.results.bindings[0].Rare_Diseases.value}
}
```