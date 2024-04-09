# [PCF] FILTER: GET All GENE IDs - https://pubcasefinder-rdf.dbcls.jp/sparql
## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `all_gene_id` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX sio: <http://semanticscience.org/resource/>

SELECT DISTINCT 
CONCAT('GENEID:', STR(?all_gene_id)) as ?all_gene_id

WHERE {
  ?an sio:SIO_000628 ?all_gene_uri .
  #FILTER(CONTAINS(STR(?all_gene_uri), "ncbigene"))
  ?all_gene_uri dcterms:identifier ?all_gene_id .
}
```

## Output
```javascript
({all_gene_id})=>{ 
  var pcf_gene = all_gene_id.results.bindings;

  var result = {}
  
  result['all_gene_id'] = new Set();
  
  for (let i = 0; i < pcf_gene.length; i++) {
    result['all_gene_id'].add(pcf_gene[i].all_gene_id.value);
  }
  
  result['all_gene_id'] = Array.from(result['all_gene_id'])
  
  return result
}
```