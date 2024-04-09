# FILTER: Get OMIM ID by HPO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
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
PREFIX oa: <http://www.w3.org/ns/oa#>

SELECT DISTINCT
?omim_id

WHERE {
  ?hpo_url rdfs:subClassOf* hpo:{{hpo_id_list}} .
  ?an rdf:type oa:Annotation ;
      oa:hasTarget ?omim_url ;
      oa:hasBody ?hpo_url ;
      dcterms:source [dcterms:creator ?creator] .
  FILTER(?creator NOT IN("Database Center for Life Science"))
  ?omim_url dcterms:identifier ?omim_id .
  FILTER(CONTAINS(STR(?omim_url), "mim"))
} order by ?omim_id
```

## `return`
```javascript
({hpo_id_list, result})=>{ 
  var list = []
  var dic = {}
  var rows = result.results.bindings;
  
  for (let i = 0; i < rows.length; i++) {
    list.push('OMIM:' + rows[i].omim_id.value);
  }

  if(rows){
    dic['HP:' + hpo_id_list] = list;
  }
  
  return dic
};