# [PCF] Get MONDO category data by MONDO ID - https://pubcasefinder-rdf.dbcls.jp/sparql
## Parameters
* `mondo_id` MONDO ID
  * default: 0020583
  * example: 0003847, 0018096, 0007477, 0001046

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
PREFIX hoom: <http://www.semanticweb.org/ontology/HOOM#>
PREFIX mondo: <http://purl.obolibrary.org/obo/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX oboinowl: <http://www.geneontology.org/formats/oboInOwl#>

SELECT DISTINCT
str(?mondo_category) as ?mondo_category
str(?name) as ?name
WHERE { 
  #VALUES ?mondo { mondo:MONDO_{{mondo_id_list}} }
  
  mondo:MONDO_{{mondo_id_list}} rdfs:subClassOf+ ?mondo_category .
  #?mondo_category rdfs:subClassOf mondo:MONDO_0700096 .
  ?mondo_category rdfs:subClassOf mondo:MONDO_0000001  .
  ?mondo_category rdfs:label ?name .
 
} order by ?name
```

SELECT DISTINCT ?mondo_category ?sub_mondo_id ?name WHERE { 
  {
    SELECT DISTINCT ?mondo_category WHERE { 
      #?mondo_category rdfs:subClassOf mondo:MONDO_0700096 .
      ?mondo_category rdfs:subClassOf mondo:MONDO_0000001 .
    }
  }
  ?sub_mondo_id rdfs:subClassOf+ ?mondo_category .
  ?sub_mondo_id rdfs:label ?name .
} order by ?mondo_category

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