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

SELECT COUNT(DISTINCT ?ncbi_gene_url) as ?Genes
WHERE {
  ?as rdf:type sio:SIO_000983 ;
    sio:SIO_000628 ?ncbi_gene_url ;
    sio:SIO_000628 ?disease_url .
  ?ncbi_gene_url rdf:type ncit:C16612 ;
    dcterms:identifier ?ncbi_gene_id ;
    sio:SIO_000205 ?hgnc_gene_url .
  ?disease_url rdf:type ncit:C7057 .
  OPTIONAL { ?ncbi_gene_url dcterms:description ?full_name . }
  ?hgnc_gene_url rdfs:label ?hgnc_gene_symbol . 
}
```

## Output
```javascript
({result})=>{
  return {"Genes":result.results.bindings[0].Genes.value}
}
```