# [PCF] FILTER: GET GENE IDs by MONDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0018096
  * example: 0003847, 0018096, 0007477

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = mondo_id.replace(/MONDO:/g,"")
  return mondo_id;
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

#SELECT ?mondo_sub_tier ?disease ?gene COUNT(DISTINCT ?gene)
#SELECT COUNT(DISTINCT ?gene) as ?count
#SELECT DISTINCT ?mondo_id
SELECT DISTINCT ?hgnc_gene_symbol
WHERE {
  {
    SELECT DISTINCT ?disease ?mondo_sub_tier WHERE { 
      #?mondo_sub_tier rdfs:subClassOf* mondo:MONDO_0003847 ;
      #?mondo_sub_tier rdfs:subClassOf* mondo:MONDO_0000001 ;
      ?mondo_sub_tier rdfs:subClassOf* mondo:MONDO_{{mondo_id_list}} ;
                      skos:exactMatch ?exactMatch_disease .

      FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
      BIND (IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .
    }
  }

  #?disease rdfs:seeAlso mondo:MONDO_{{mondo_id_list}} .
  #?as sio:SIO_000628 [rdfs:seeAlso mondo:MONDO_{{mondo_id_list}}] ;
  ?as sio:SIO_000628 ?disease ;
      sio:SIO_000628 ?gene .
  ?disease rdf:type ncit:C7057 .
  ?gene rdf:type ncit:C16612 ;
        sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] . 
}
#order by ?mondo_sub_tier
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