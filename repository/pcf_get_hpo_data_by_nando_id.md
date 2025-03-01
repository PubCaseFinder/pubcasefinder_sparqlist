# [PCF] Get HPO data by MONDO ID - https://dev-pubcasefinder.dbcls.jp/sparql
## Parameters
* `nando_id` MONDO ID
  * default: 1200001
  * example: 1200404, 1201073, 1200010, 120011

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql

## `nando_id_list`
```javascript
({nando_id}) => {
  nando_id = nando_id.replace(/NANDO:/g,"")
  nando_id = 'nando:' + nando_id.replace(/[\s,]+/g," nando:")
  return nando_id;
}
```

## `result` 
```sparql
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX nando: <http://nanbyodata.jp/ontology/NANDO_>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/HP_>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX sio: <http://semanticscience.org/resource/>
SELECT DISTINCT ?hpo_id
WHERE 
{
  VALUES ?nando_input { {{nando_id_list}}  }
  
  
  #?nando rdf:type owl:Class .
  #FILTER(CONTAINS(STR(?nando), "NANDO_12"))

  ?nando_input skos:exactMatch ?mondo_exactMatch .
  ?disease_url rdfs:seeAlso ?mondo_exactMatch .

  #?nando_input skos:exactMatch ?mondo_exactMatch .
  #?mondo_sub_tier rdfs:subClassOf* ?mondo_exactMatch .
  #?disease_url rdfs:seeAlso ?mondo_sub_tier .
  

  ?dpa rdf:type oa:Annotation ;
       oa:hasBody ?hpo ;
       oa:hasTarget ?disease_url ;
       dcterms:source [dcterms:creator ?creator] .
  FILTER(?creator NOT IN("Database Center for Life Science"))
  
  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp>{
    ?hpo rdfs:subClassOf+ ?hpo_category .
    ?hpo_category rdfs:subClassOf obo:0000118 .   
  }
  
  #?hpo <http://www.geneontology.org/formats/oboInOwl#id> ?hpo_id .
  BIND (IRI(replace(STR(?hpo), 'http://purl.obolibrary.org/obo/HP_', 'HP:')) AS ?hpo_id)
  
#  optional {
#    ?hpo rdfs:label ?hpo_en, ?hpo_ja . 
#    FILTER (lang(?hpo_en) = "") .
#    FILTER (lang(?hpo_ja) = "ja") .
#  }


  #association
#  ?as sio:SIO_000628 ?disease_url ;
#      sio:SIO_000628 ?gene .
#  ?gene rdf:type ncit:C16612 ;
#        dcterms:identifier ?gene_id ;
#        sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] .
}
order by ?hpo_id
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