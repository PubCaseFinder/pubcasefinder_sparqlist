# FILTER: Get MONDO ID by HPO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `hpo_id` HPO ID
  * default: 0000347, 0003022
  * example: 0001428, 0003745

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `hpo_id_list`
```javascript
({hpo_id}) => {
  hpo_id = hpo_id.replace(/,/g," ")
   if (hpo_id.match(/[^\s]/))  return hpo_id.split(/\s+/);
  return false;
  
  //hpo_id = hpo_id.replace(/HP:/g,"")
  //hpo_id = 'obo:' + hpo_id.replace(/[\s,]+/g," obo:")
  //hpo_id = 'hpo:' + hpo_id.replace(/[\s,]+/g," hpo:")
  //return hpo_id;
}
```

## `result`
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/HP_>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX sio: <http://semanticscience.org/resource/>

#SELECT COUNT( DISTINCT ?mondo_id)
SELECT DISTINCT STR(?gene_symbol) as ?gene_symbol
#SELECT DISTINCT ?hpo_url ?disease STR(?mondo_id) as ?mondo_id STR(?mondo_disease_name_en) as ?mondo_disease_name_en

WHERE {
  {{#if hpo_id_list}}
    VALUES ?hpo { {{#each hpo_id_list}} obo:{{this}} {{/each}} }
      {{/if}}

  #VALUES ?hpo { {{hpo_id_list}} }
    
  ?hpo_url rdfs:subClassOf* ?hpo .
  ?anp rdf:type oa:Annotation ;
      oa:hasTarget ?disease_url ;
      oa:hasBody ?hpo_url ;
      dcterms:source [dcterms:creator ?creator] .
  FILTER(?creator NOT IN("Database Center for Life Science"))
  #FILTER(CONTAINS(STR(?disease_url), "mim"))
  #FILTER(CONTAINS(STR(?disease_url), "orpha"))
  
  ?disease_url rdfs:seeAlso ?mondo .
               #dcterms:identifier ?disease_id .
  ?mondo <http://www.geneontology.org/formats/oboInOwl#id> ?mondo_id .
         #rdfs:label ?mondo_disease_name_en .
  
  ?asg rdf:type sio:SIO_000983 ;
       sio:SIO_000628 ?disease_url ;
       sio:SIO_000628 ?ncbi_gene_url .
  ?disease_url rdf:type ncit:C7057 .
  ?ncbi_gene_url rdf:type ncit:C16612.
                 
  ?ncbi_gene_url sio:SIO_000205 [rdfs:label ?gene_symbol] .
}
```
## `return`
```javascript
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