# [PCF] Get MONDO category data by MONDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0005180
  * example: 0013167, 0018096, 0007477, 0001046

## Endpoint
https://pubcasefinder-rdf.dbcls.jp/sparql

## `mondo_id_list`
```javascript
({mondo_id}) => {
  mondo_id = mondo_id.replace(/[MONDO:\s,]+/gi,"")
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

SELECT DISTINCT COUNT(DISTINCT ?parent_count) as ?root_count ?root_node ?root_name ?parent_id ?parent_name ?child_id ?child_name

WHERE {
  VALUES ?root_node { mondo:MONDO_{{mondo_id_list}} }
  #VALUES ?root_node { mondo:MONDO_0013167 }

  ?root_node rdfs:subClassOf+ mondo:MONDO_0000001 .
  ?root_node rdfs:label ?root_name .

  optional {
    ?parent_id  rdfs:subClassOf* ?root_node .
    ?child_id rdfs:subClassOf ?parent_id .

    ?child_id rdfs:label ?child_name .
    ?parent_id rdfs:label ?parent_name .

    ?parent_count  rdfs:subClassOf ?root_node .
  }
} order by ?parent_name ?child_name

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