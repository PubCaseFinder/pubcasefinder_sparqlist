# [PCF] Get GPA - https://pubcasefinder-rdf.dbcls.jp/sparql
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

SELECT DISTINCT
?ncbi_gene_id
?hpo_id
?mondo_id
?disease
?source

WHERE { 
  ?as rdf:type sio:SIO_000983 ;
      sio:SIO_000628 ?disease_url ;
      sio:SIO_000628 ?ncbi_gene_url .
  ?disease_url rdf:type ncit:C7057 .
  ?ncbi_gene_url rdf:type ncit:C16612.
  ?an rdf:type oa:Annotation ;
      oa:hasTarget ?disease_url ;
      oa:hasBody ?hpo_url ;
      dcterms:source [dcterms:creator ?creator] .
  ?disease_url rdfs:seeAlso [<http://www.geneontology.org/formats/oboInOwl#id> ?mondo_id] .
  
  BIND(REPLACE(STR(?ncbi_gene_url), 'http://identifiers.org/ncbigene/', 'GENEID:') AS ?ncbi_gene_id)
  BIND(IF(regex(?disease_url, 'http://www.orpha.net/ORDO/Orphanet_[0-9]'), 'Orphanet', 'OMIM') AS ?disease)
  BIND(IF(?creator = 'Human Phenotype Ontology Consortium', 'HPO', if(?creator = 'Database Center for Life Science', 'DBCLS', 'Orphanet')) AS ?source)
  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp> {
    ?hpo_url <http://www.geneontology.org/formats/oboInOwl#id> ?hpo_id .
  }
} order by ?ncbi_gene_id ?source
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