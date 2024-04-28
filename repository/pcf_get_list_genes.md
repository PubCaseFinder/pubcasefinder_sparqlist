# [PCF] List_Genes - https://pubcasefinder-rdf.dbcls.jp/sparql

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>

SELECT DISTINCT
CONCAT('GENEID:', STR(?ncbi_gene_id)) as ?ncbi_gene_id
str(?ncbi_gene_url) as ?ncbi_gene_url
STR(?hgnc_gene_symbol) as ?hgnc_gene_symbol
STR(?hgnc_gene_url) as ?hgnc_gene_url
str(?full_name) as ?full_name
WHERE { 
  
  ?as rdf:type sio:SIO_000983 ;
      sio:SIO_000628 ?ncbi_gene_url ;
      sio:SIO_000628 ?disease_url .
  ?ncbi_gene_url rdf:type ncit:C16612 ;
                 dcterms:identifier ?ncbi_gene_id ;
                 sio:SIO_000205 ?hgnc_gene_url .
  ?an rdf:type oa:Annotation ;
        oa:hasTarget ?disease_url ;
        oa:hasBody ?hpo_url ;
        dcterms:source [dcterms:creator ?creator] .
  FILTER(?creator NOT IN("Database Center for Life Science"))
  OPTIONAL { ?ncbi_gene_url dcterms:description ?full_name . }
  ?hgnc_gene_url rdfs:label ?hgnc_gene_symbol .
  
  ?disease_url rdf:type ncit:C7057 .
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