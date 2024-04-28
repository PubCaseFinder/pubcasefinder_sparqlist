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
  ?mondo_id
  ?panel_name
  (GROUP_concat(distinct ?panel_name_ja; separator = " | ") as ?panel_name_ja)
  COUNT(DISTINCT ?gene) as ?count
WHERE {
  {
    SELECT DISTINCT ?mondo_list ?exactMatch_disease WHERE { 
      {
        SELECT DISTINCT ?mondo_list WHERE { 
          ?mondo_list rdfs:subClassOf+ mondo:MONDO_0000001 .
          MINUS { ?mondo_list owl:deprecated ?deprecated . }
        }
      }
      ?mondo_sub_tier rdfs:subClassOf* ?mondo_list ;
                      skos:exactMatch ?exactMatch_disease .
    }
  } 
  #FILTER(CONTAINS(STR(?exactMatch_disease), "omim") || CONTAINS(STR(?exactMatch_disease), "Orphanet"))
  BIND (IRI(replace(STR(?exactMatch_disease), 'http://identifiers.org/omim/', 'http://identifiers.org/mim/')) AS ?disease) .

  ?as sio:SIO_000628 ?disease ;
      sio:SIO_000628 ?gene .
  ?disease rdf:type ncit:C7057 .

  ?gene rdf:type ncit:C16612  . 
  
  ?mondo_list oboinowl:id ?mondo_id ;
              rdfs:label ?panel_name .
  optional {
    ?disease_name rdfs:seeAlso ?mondo_list .
    ?disease_name rdfs:label ?panel_name_ja .
    FILTER (lang(?panel_name_ja) = "ja")
  }
} 
#order by ?panel_name
order by ?mondo_id
```

## Output
```javascript
({result})=>{ 
  return result.results.bindings.map(data => {
    return Object.keys(data).reduce((obj, key) => {
      obj[key] = data[key].value;
      return obj;
    }, {});
  });
}
```