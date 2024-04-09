# ranking_phenotype_association
## Parameters
* `hgnc_gene_symbol`
  * default: POLG SLC7A7 CBS
  * example: 6710, 6521

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `hgnc_gene_symbol_list`
```javascript
({hgnc_gene_symbol}) => {
  hgnc_gene_symbol = '\"' + hgnc_gene_symbol.replace(/[\s,]+/g,"\" \"") + '\"'
  return hgnc_gene_symbol;
}
```

## `result`
```sparql
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mim: <http://identifiers.org/mim/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX nando: <http://nanbyodata.jp/ontology/nando#>
PREFIX ncbigene: <http://identifiers.org/ncbigene/>

SELECT DISTINCT
COUNT(?hpo_url)
WHERE {
  VALUES ?HGNC_Symbol { {{hgnc_gene_symbol_list}} }
  
  ?HGNC_id rdfs:label ?HGNC_Symbol .
  ?ncbi_gene_url sio:SIO_000205 ?HGNC_id .

  ?as rdf:type sio:SIO_000983 ;
      sio:SIO_000628 ?ncbi_gene_url ;
      sio:SIO_000628 ?disease_url .
  ?ncbi_gene_url rdf:type ncit:C16612 .

  ?an rdf:type oa:Annotation ;
      oa:hasTarget ?disease_url ;
      oa:hasBody ?hpo_url .

}
```