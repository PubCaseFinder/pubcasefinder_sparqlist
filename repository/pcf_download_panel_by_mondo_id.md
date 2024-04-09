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
PREFIX dcterm: <http://purl.org/dc/terms/>
PREFIX ncit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT
?hgnc_gene_symbol 
(GROUP_concat(distinct ?disease_name; separator = " | ") as ?disease_name)
(GROUP_concat(distinct ?source_name; separator = " | ") as ?source_name)
WHERE {
  {
    SELECT DISTINCT ?disease WHERE { 
      ?mondo_sub_tier rdfs:subClassOf* mondo:MONDO_{{mondo_id_list}} ;
      				  skos:exactMatch ?exactMatch_disease .
      FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
      BIND(IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .
    }
  }
  ?as sio:SIO_000628 ?disease ;
      sio:SIO_000628 ?gene ;
      dcterm:source ?source .
  ?disease rdf:type ncit:C7057 ;
           rdfs:seeAlso [rdfs:label ?disease_name] .
  ?gene rdf:type ncit:C16612 ;
        sio:SIO_000205 [rdfs:label ?hgnc_gene_symbol] ;
        dcterm:identifier ?gene_id . 
  
  BIND(IF(STR(?source) = 'http://www.orphadata.org/data/xml/en_product6.xml', 'Orphadata',
       IF(STR(?source) = 'ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/mim2gene_medgen', 'OMIM', 'GenCC')) AS ?source_name)
} order by ?hgnc_gene_symbol
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