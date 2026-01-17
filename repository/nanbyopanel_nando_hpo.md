# [PCF] Get HPO data by MONDO ID - https://dev-pubcasefinder.dbcls.jp/sparql
## Parameters
* `nando_id` NANDO ID
  * default: 1200001
  * example: 1200404, 1201073, 1200010, 120011

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql

## `nando_id_list`
```javascript
({nando_id}) => {
  nando_id = nando_id.replace(/NANDO:/g,"")
  nando_id = 'NANDO:' + nando_id.replace(/[\s,]+/g," NANDO:")
  return nando_id;
}
```

## `result` 
```sparql
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX NANDO: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX obo: <http://purl.obolibrary.org/obo/HP_>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>

SELECT DISTINCT ?hpo_id
WHERE 
{
  VALUES ?nando { {{nando_id_list}}  }
  ?nando skos:exactMatch ?mondo .
  ?disease_url rdfs:seeAlso ?mondo .
  ?an rdf:type oa:Annotation ;
      oa:hasTarget ?disease_url ;
      oa:hasBody ?hpo_url ;
      dcterms:source [dcterms:creator ?creator] .
  FILTER(?creator NOT IN("Database Center for Life Science"))
  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
    ?hpo_url rdfs:subClassOf+ ?hpo_category .
    ?hpo_category rdfs:subClassOf obo:0000118 .   
  }
 ?hpo_url oboInOwl:id ?hpo_id .
}
ORDER BY ?hpo_id
```
## `return`
```javascript
({text({result}){ // tsv
    var vars = result.head.vars;
    var list = result.results.bindings;
    var text = ""
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