# [PCF] EXPAND: min200 only one - https://dev-pubcasefinder.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0010011 0043275
  * example: 0018096, 0003847, 0018096, 0007477

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql
* 'https://dev-pubcasefinder.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = mondo_id.replace(/MONDO:/g,"")
  mondo_id = 'mondo:MONDO_' + mondo_id.replace(/[\s,]+/g," mondo:MONDO_")
  return mondo_id;
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>

#SELECT ?mondo_input (STR(?mondo_id) AS ?mondo) ?count
#SELECT (STR(?mondo_id) AS ?mondo)
SELECT ?mondo
WHERE {
  VALUES ?mondo_input { {{mondo_id_list}} }

  {
    SELECT ?mondo_input ?mondo (MIN(ABS(xsd:integer(?count) - 200)) AS ?min_diff)
    WHERE {
      ?mondo_input rdfs:subClassOf* ?sup .
      ?sup sio:SIO_001112 ?count ;
           oboInOwl:id ?mondo .
      FILTER(xsd:integer(?count) >= 200)
    }
    GROUP BY ?mondo_input ?mondo
  }

  {
    SELECT ?mondo_input (MIN(ABS(xsd:integer(?count) - 200)) AS ?min_diff_val)
    WHERE {
      ?mondo_input rdfs:subClassOf* ?sup .
      ?sup sio:SIO_001112 ?count .
      FILTER(xsd:integer(?count) >= 200)
    }
    GROUP BY ?mondo_input
  }

  FILTER(?min_diff = ?min_diff_val)
}
```

## Output
```javascript
({ result }) => {
  return result.results.bindings.map(data => data["mondo"].value);
}