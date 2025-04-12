# FILTER: Get GENE ID by HPO ID - https://dev-pubcasefinder.dbcls.jp/sparql
## Parameters
* `hpo_id` HPO ID
  * default: 0001263
  * example: 0010636, 0100021, 0002126

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql

## `hpo_id_list`
```javascript
({hpo_id}) => {
  hpo_id = hpo_id.replace(/HP:/g,"")
  hpo_id = 'hpo:' + hpo_id.replace(/[\s,]+/g," hpo:")
  return hpo_id;
}
```

## `result`
```sparql
# @endpoint https://dev-pubcasefinder.dbcls.jp/sparql/
# @temp-proxy true
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX hpo: <http://purl.obolibrary.org/obo/HP_>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX oboinowl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX obo: <http://purl.obolibrary.org/obo/HP_>

SELECT DISTINCT 
?nando 
WHERE {
  VALUES ?hpo { {{hpo_id_list}} }
  ?hpo_list rdfs:subClassOf* ?hpo .

  # Disease Phenotype Association
  ?dpa rdf:type oa:Annotation ;
       oa:hasBody ?hpo_list ;
       oa:hasTarget ?disease_url ;
       dcterms:source [dcterms:creator ?creator] .
  FILTER(?creator NOT IN("Database Center for Life Science"))
  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
    ?hpo_list rdfs:subClassOf+ ?hpo_category .
    ?hpo_category rdfs:subClassOf obo:0000118 .   
  }
  # Disease Gene Association
  ?as sio:SIO_000628 ?disease_url ;
      sio:SIO_000628 ?gene .
  ?gene rdf:type ncit:C16612 .
  #BIND (IRI(replace(STR(?disease_url), 'http://identifiers.org/mim/', 'https://omim.org/entry/')) AS ?exactMatch_disease) .
  #?mondo_exactMatch skos:exactMatch ?exactMatch_disease .
  
  ?disease_url rdfs:seeAlso ?mondo_exactMatch .
  ?nando skos:exactMatch ?mondo_exactMatch .
  ?nando rdf:type owl:Class .
  FILTER(CONTAINS(STR(?nando), "NANDO_12"))
  FILTER NOT EXISTS { ?nando nando:memberOf ?member }
}
ORDER BY ?nando

```

## `return`
```javascript
/*
({result})=>{ // json
  return result.results.bindings.map(data => {
    return Object.keys(data).reduce((obj, key) => {
      obj[key] = data[key].value;
      return obj;
    }, {});
  });
*/
({text({result}){ // tsv
    var vars = result.head.vars;
    var list = result.results.bindings;
    var text = vars.join("\t") + "\n";
    for(var i = 0; i < list.length; i++){
      var values = [];
      for(var j = 0; j < vars.length; j++){
        var val = ""; 
        if(list[i][vars[j]]) val = list[i][vars[j]].value;
        if(val.match(/^\".+\"$/)) val = val.match(/^\"(.+)\"$/)[1];
        values.push(val);
      }
      text += values.join("\t") + "\n";
    }
    return text;
  }
})
```