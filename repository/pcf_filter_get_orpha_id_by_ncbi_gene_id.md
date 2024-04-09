# FILTER: GET ORPHA IDs by NCBI gene ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `ncbi_gene_id` NCBI gene ID
  * default: 10771
  * example: 10771, 583, 6696

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `ncbi_gene_id_list`
```javascript
({ncbi_gene_id}) => {
  ncbi_gene_id = ncbi_gene_id.replace(/GENEID:/g,"")
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
?orpha_id

WHERE {
  #GRAPH <https://pubcasefinder.dbcls.jp/rdf> {
    ?as sio:SIO_000628 ?orpha_uri ;
        sio:SIO_000628 ncbigene:{{ncbi_gene_id_list}} .
    ?orpha_uri rdf:type ncit:C7057 .
    ?orpha_uri dcterms:identifier ?orpha_id .
    ncbigene:{{ncbi_gene_id_list}} rdf:type ncit:C16612 .
    FILTER(CONTAINS(STR(?orpha_uri), "Orphanet_"))
  #}
} order by ?orpha_id
```

## `return`
```javascript
({ncbi_gene_id_list, result})=>{ 
  var list = []
  var dic = {}
  var rows = result.results.bindings;
  
  for (let i = 0; i < rows.length; i++) {
    list.push('ORPHA:' + rows[i].orpha_id.value);
  }

  if(rows){
    dic['GENEID:' + ncbi_gene_id_list] = list;
  }
  
  return dic
};