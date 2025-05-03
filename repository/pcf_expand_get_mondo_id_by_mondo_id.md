# [PCF] EXPAND: min200 only one - https://dev-pubcasefinder.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0020341
  * example: 0018096, 0003847, 0018096, 0007477

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql

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
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

#SELECT DISTINCT *
SELECT DISTINCT STR(?mondo) as ?mondo
#SELECT DISTINCT STR(?mondo) as ?mondo ?count
WHERE {
  {
    SELECT DISTINCT ?mondo_sup_tier WHERE {
      mondo:MONDO_{{mondo_id_list}} rdfs:subClassOf* ?mondo_sup_tier .      
      FILTER(CONTAINS(STR(?mondo_sup_tier), "MONDO"))
    }
  }
  ?mondo_sup_tier sio:SIO_001112 ?count .
  FILTER(DATATYPE(?count) = xsd:integer)
  FILTER(?count > 200)
  ?mondo_sup_tier <http://www.geneontology.org/formats/oboInOwl#id> ?mondo .
}
ORDER BY ABS(?count - 200)
LIMIT 1
```

## Output
```javascript
({ result }) => {
  return result.results.bindings.map(data => data["mondo"].value);
}