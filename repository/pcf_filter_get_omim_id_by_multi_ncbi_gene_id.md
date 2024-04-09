# FILTER: GET OMIM IDs by multi NCBI gene ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `ncbi_gene_id` NCBI gene ID
  * default: 57514 6521
  * example: 6710 6521

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `ncbi_gene_id_list`
```javascript
({ncbi_gene_id}) => {
  ncbi_gene_id = ncbi_gene_id.replace(/GENEID:/g,"")
  ncbi_gene_id = 'ncbigene:' + ncbi_gene_id.replace(/[\s,]+/g," ncbigene:")
  return ncbi_gene_id;
}
```

## `result`
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncbigene: <http://identifiers.org/ncbigene/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX sio: <http://semanticscience.org/resource/>

SELECT DISTINCT
?omim_id

WHERE {
  VALUES ?ncbi_gene_url { {{ncbi_gene_id_list}} }
  #GRAPH <https://pubcasefinder.dbcls.jp/rdf> {
  ?ncbi_gene_url rdf:type ncit:C16612 .  
  ?omim_uri rdf:type ncit:C7057 .
  ?as sio:SIO_000628 ?omim_uri ;
      sio:SIO_000628 ?ncbi_gene_url .
  ?omim_uri dcterms:identifier ?omim_id .    
  FILTER(CONTAINS(STR(?omim_uri), "mim"))
  #}
} order by ?omim_id
```

## `return`
```javascript
({ncbi_gene_id_list, result})=>{ 
  var list = []
  var dic = {}
  var rows = result.results.bindings;
  
  for (let i = 0; i < rows.length; i++) {
    list.push('OMIM:' + rows[i].omim_id.value);
  }
  return list
/*
  if(rows){
    dic['GENEID:' + ncbi_gene_id_list] = list;
  }
  
  return dic
*/
};