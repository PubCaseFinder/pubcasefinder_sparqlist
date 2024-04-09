# [PCF] Statistics_Genes - https://pubcasefinder-rdf.dbcls.jp/sparql

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX sio: <http://semanticscience.org/resource/>

SELECT COUNT(DISTINCT ?ncbigene) as ?Genes

WHERE {
  ?as sio:SIO_000628 ?disease ;
      sio:SIO_000628 ?ncbigene .
  ?disease rdf:type ncit:C7057 .
  ?ncbigene rdf:type ncit:C16612 .
  ?an rdf:type oa:Annotation ;
        oa:hasTarget ?disease ;
        oa:hasBody ?hpo_url ;
        dcterms:source [dcterms:creator ?creator] .
    #FILTER(CONTAINS(STR(?disease), "mim"))
	#FILTER(CONTAINS(STR(?disease), "ORDO"))
    FILTER(?creator NOT IN("Database Center for Life Science"))
  
}
```

## Output
```javascript
({result})=>{
  return {"Genes":result.results.bindings[0].Genes.value}
}
```