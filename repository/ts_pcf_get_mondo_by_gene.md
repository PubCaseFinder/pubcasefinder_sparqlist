# pcf_convert_genesymbol_to_ncbigeneid
## Parameters
* `hgnc_gene_symbol`
  * default: POLG SLC7A7 CBS
  * example: POLG SLC7A7 CBS

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
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>

SELECT DISTINCT
?hgnc_gene_symbol
?ncbi_gene_id
#?disease
STR(?mondo_id) as ?mondo_id
WHERE {
  VALUES ?hgnc_gene_symbol { {{hgnc_gene_symbol_list}} }
  
  ?HGNC_id rdfs:label ?hgnc_gene_symbol .
  ?ncbi_gene_url sio:SIO_000205 ?HGNC_id ;
                 rdf:type ncit:C16612 ;
                 dcterms:identifier ?ncbi_gene_id .
  ?as sio:SIO_000628 ?disease ;
      sio:SIO_000628 ?ncbi_gene_url .
  ?disease rdf:type ncit:C7057 .
  ?disease rdfs:seeAlso ?mondo .
  ?mondo <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_id .
}
```