# [PCF] Get HPO data by ORPHA ID - https://dev-pubcasefinder.dbcls.jp/sparql
## Parameters
* `orpha_id` ORPHA ID
  * default: 245
  * example: 245, 52, 140952, 1784

## Endpoint
https://dev-pubcasefinder.dbcls.jp/sparql

## `orpha_id_list`
```javascript
({orpha_id}) => {
  orpha_id = orpha_id.replace(/ORPHA:/g,"")
  return orpha_id;
}
```

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX hoom: <http://www.semanticweb.org/ontology/HOOM#>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ordo: <http://www.orpha.net/ORDO/>

SELECT DISTINCT
  str(?hpo_id) as ?hpo_id
  str(?hpo_url) as ?hpo_url
  str(?hpo_label_en) as ?hpo_label_en
  str(?hpo_label_ja) as ?hpo_label_ja
  str(?definition) as ?definition
  str(?frequency) as ?frequency
WHERE {
  VALUES ?orpha_id { ordo:Orphanet_{{orpha_id_list}} }

  ?an rdf:type oa:Annotation ;
      oa:hasTarget ?orpha_id ;
      oa:hasBody ?hpo_url ;
      dcterms:source [ dcterms:creator ?creator ] .

  OPTIONAL {
    ?an hoom:with_frequency [ rdfs:label ?frequency ] .
    FILTER(LANG(?frequency) = "en")
  }

  FILTER(CONTAINS(STR(?orpha_id), "ORDO"))
  FILTER(?creator NOT IN("Database Center for Life Science"))

  GRAPH <https://pubcasefinder.dbcls.jp/rdf/ontology/hp> {
    ?hpo_url rdfs:label ?hpo_label_en .
    FILTER(lang(?hpo_label_en) = "")

    BIND(replace(str(?hpo_url), 'http://purl.obolibrary.org/obo/HP_', 'HP:') AS ?hpo_id)

    OPTIONAL {
      ?hpo_url obo:IAO_0000115 ?definition .
    }
  }

  OPTIONAL {
    ?hpo_url rdfs:label ?hpo_label_ja .
    FILTER(lang(?hpo_label_ja) = "ja")
  }
}
ORDER BY ?hpo_id
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