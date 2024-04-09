# [PCF] Get all panel - https://pubcasefinder-rdf.dbcls.jp/sparql
## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX oboinowl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

SELECT DISTINCT 
?panel_name
(GROUP_concat(distinct ?panel_name_synonym; separator = " | ") as ?panel_name_synonym)
?panel_name_ja
?mondo_id
COUNT(DISTINCT ?gene_symbol_list) as ?gene_count
(GROUP_concat(distinct ?gene_symbol_list; separator = " | ") as ?gene_symbol_list)

WHERE {
  {
    SELECT DISTINCT ?mondo_list ?gene_symbol_list WHERE { 
      {
        SELECT DISTINCT ?mondo_list WHERE { 
          ?mondo_list rdfs:subClassOf+ mondo:MONDO_0000001 .
        }
      }
      optional { ?mondo_list owl:deprecated ?deprecated . }
      FILTER (!BOUND(?deprecated)) .
      
      ?mondo_sub_tier rdfs:subClassOf* ?mondo_list ;
                      skos:exactMatch ?exactMatch_disease .

      FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
      BIND (IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .

      ?as sio:SIO_000628 ?disease ;
          sio:SIO_000628 ?gene .
      ?disease rdf:type ncit:C7057 .
      ?gene rdf:type ncit:C16612 ;
            sio:SIO_000205 [rdfs:label ?gene_symbol_list] ;
            dcterms:identifier ?gene_id . 
    }
  } 
  ?mondo_list oboinowl:id ?mondo_id ;
              rdfs:label ?panel_name .
  optional { ?mondo_list oboinowl:hasExactSynonym ?panel_name_synonym }
  optional {
    ?disease_name rdfs:seeAlso ?mondo_list .
    ?disease_name rdfs:label ?panel_name_ja .
    FILTER (lang(?panel_name_ja) = "ja")
  }
}
#order by ?mondo_id
```

## Output
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