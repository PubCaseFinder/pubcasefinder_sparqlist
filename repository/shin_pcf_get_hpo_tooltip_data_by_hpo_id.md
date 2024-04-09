# [PCF] Get HPO tooltip data by HPO ID 
## Parameters
* `hpo_id` HPO ID
  * default: 0000347
  * example: 0410219, 0031815, 0040184

## Endpoint
https://integbio.jp/rdf/sparql

## `result` 
```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX mim: <http://identifiers.org/mim/>
PREFIX oa: <http://www.w3.org/ns/oa#>
PREFIX obo: <http://purl.obolibrary.org/obo/>

SELECT DISTINCT
str(?name_en) as ?name_en
str(?name_ja) as ?name_ja
str(?definition) as ?definition
str(?comment) as ?comment
(GROUP_CONCAT(DISTINCT ?synonym; separator="|") AS ?synonyms)
str(?hpo_url) as ?hpo_url
WHERE
{ 
    VALUES ?hp_id { obo:HP_{{hpo_id}} }

    GRAPH <http://integbio.jp/rdf/ontology/hp>{
      optional { ?hp_id rdfs:label ?name_en . }
      optional { ?hp_id obo:IAO_0000115 ?definition . }
      optional { ?hp_id <http://www.geneontology.org/formats/oboInOwl#hasExactSynonym> ?synonym . }
      optional { ?hp_id rdfs:comment ?comment . }
    }
    optional { ?hp_id rdfs:seeAlso ?hpo_url . }
    optional { ?hp_id rdfs:label ?name_ja . FILTER (lang(?name_ja) = "ja") }
}
```

## Output
```javascript
({result})=>{ 
  return result.results.bindings.map((elem) => ({
    name_en: getValue(elem.name_en),
	name_ja: getValue(elem.name_ja),
	definition: getValue(elem.definition),
	comment: getValue(elem.comment),
    hpo_url: getValue(elem.hpo_url),
    synonyms: getValue(elem.synonyms),
  }));
  function getValue(obj) {
    if (obj) {
      return obj.value;
    } else {
      return '';
    }
  }
}
```