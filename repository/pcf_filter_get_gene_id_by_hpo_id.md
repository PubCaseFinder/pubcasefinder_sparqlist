# FILTER: Get GENE ID by HPO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `hpo_id` HPO ID
  * default: 0009381
  * example: 0001428, 0003745

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `hpo_id_list`
```javascript
({hpo_id}) => {
  hpo_id = hpo_id.replace(/HP:/g,"")
  //hpo_id = 'hpo:' + hpo_id.replace(/[\s,]+/g," hpo:")
  return hpo_id;
}
```

## `result`
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX hpo: <http://purl.obolibrary.org/obo/HP_>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX oa: <http://www.w3.org/ns/oa#>

SELECT DISTINCT
?gene_id

WHERE {
  ?hpo_url rdfs:subClassOf* hpo:{{hpo_id_list}} .
  ?an rdf:type oa:Annotation ;
      oa:hasTarget ?disease ;
      oa:hasBody ?hpo_url ;
      dcterms:source [dcterms:creator ?creator] .
  FILTER(?creator NOT IN("Database Center for Life Science"))
  ?as sio:SIO_000628 ?disease ;
      sio:SIO_000628 ?gene_url .
  ?disease rdf:type ncit:C7057 .
  ?gene_url rdf:type ncit:C16612 .
  ?gene_url dcterms:identifier ?gene_id .
} order by ?gene_id
```

## `return`
```javascript
({hpo_id_list, result})=>{ 
  var list = []
  var dic = {}
  var rows = result.results.bindings;
  
  for (let i = 0; i < rows.length; i++) {
    list.push('GENEID:' + rows[i].gene_id.value);
  }

  if(rows){
    dic['HP:' + hpo_id_list] = list;
  }
  
  return dic
};