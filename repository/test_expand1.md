# [PCF] EXPAND: one path up only one - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0020341
  * example: 0018096, 0003847, 0018096, 0007477

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

SELECT STR(?mondo) as ?mondo ?count
WHERE {
  {
    SELECT DISTINCT ?mondo_sup_tier WHERE {
      mondo:MONDO_{{mondo_id_list}} rdfs:subClassOf ?mondo_sup_tier .      
      FILTER(CONTAINS(STR(?mondo_sup_tier), "MONDO"))
    }
  }
  {
    SELECT DISTINCT ?mondo_sup_tier COUNT(DISTINCT ?gene) as ?count WHERE {
      ?mondo_sub_tier rdfs:subClassOf* ?mondo_sup_tier ;
                      skos:exactMatch ?exactMatch_disease .
      FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
      BIND (IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .
      ?as sio:SIO_000628 ?disease ;
          sio:SIO_000628 ?gene .
      ?disease rdf:type ncit:C7057 .
      ?gene rdf:type ncit:C16612 ;
            dcterms:identifier ?gene_id . 
    }
  }
  ?mondo_sup_tier <http://www.geneontology.org/formats/oboInOwl#id> ?mondo .
} order by ?count
#SELECT DISTINCT ?mondo_sup
#WHERE {
#  {
#    SELECT DISTINCT ?mondo_sup WHERE {
#      mondo:MONDO_{{mondo_id_list}} rdfs:subClassOf ?mondo_sup_tier .
#      FILTER(CONTAINS(STR(?mondo_sup_tier), "MONDO"))
#      BIND (IRI(replace(STR(?mondo_sup_tier), 'http://purl.obolibrary.org/obo/MONDO_', '')) AS ?mondo_sup) .
#    }
#  }
#}
```

## Output
```javascript
({mondo_id_list, result})=>{ 
  var rows = result.results.bindings;
  var list = []
  var min = 9999;
  var temp = 0;
  
  for (let i = 0; i < rows.length; i++) {
    if (0 != parseInt(rows[i].count.value) && min >= parseInt(rows[i].count.value))
    {
      min = rows[i].count.value;
      temp = i;
    }
  }
  list.push(rows[temp].mondo.value);
  return list
}