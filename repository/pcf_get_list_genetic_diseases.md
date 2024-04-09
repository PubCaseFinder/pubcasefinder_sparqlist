# [PCF] List_Genetic_Diseases - https://pubcasefinder-rdf.dbcls.jp/sparql

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
str(?omim_id) as ?omim_id
str(?mim_id) as ?omim_url
str(?disease_name_en) as ?omim_disease_name_en
str(?disease_name_ja) as ?omim_disease_name_ja
WHERE { 
  ?an rdf:type oa:Annotation ;
      oa:hasTarget ?mim_id ;
      oa:hasBody ?hpo_url ;
      dcterms:source [dcterms:creator ?creator] .
  FILTER(CONTAINS(STR(?mim_id), "mim"))
  FILTER(?creator NOT IN("Database Center for Life Science"))

  OPTIONAL {
    ?mim_id rdfs:seeAlso [rdfs:label ?disease_name_en].
    ?mim_id rdfs:label ?disease_name_ja FILTER (lang(?disease_name_ja) = "ja")
  }
  
  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
    ?hpo_url rdfs:subClassOf+ ?hpo_category .
    ?hpo_category rdfs:subClassOf obo:HP_0000118 .   
  }
  
  BIND (replace(str(?mim_id), 'http://identifiers.org/mim/', 'OMIM:') AS ?omim_id)
}
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